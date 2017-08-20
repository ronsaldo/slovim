Class {
	#name : #SLVMFunctionGCLowtalkLoweringPass,
	#superclass : #SLVMFunctionGCLoweringPass,
	#instVars : [
		'objectModel',
		'writeBarrier',
		'increaseReference',
		'releaseReference',
		'readBarrier',
		'writeBarrierNoIncrement',
		'pointerSize'
	],
	#category : #'Slovim-Core-GC'
}

{ #category : #'as yet unclassified' }
SLVMFunctionGCLowtalkLoweringPass class >> gcName [
	^ #lowtalk
]

{ #category : #applying }
SLVMFunctionGCLowtalkLoweringPass >> cleanInstructionsOf: aFunction [
	aFunction basicBlocks do: [ :bb |
		bb instructionsDo: [ :ins |
			(ins isPhi and: [ ins instructionReferences isEmpty ]) ifTrue: [ 
				ins removeFromBlock
			]
		]
	].

]

{ #category : #'reference counting' }
SLVMFunctionGCLowtalkLoweringPass >> emitAutomaticReferenceCountingOn: aFunction [
	| objectVariables afterLastAlloca returnInstructions builder cleanUpBlock returnValue |
	objectVariables := OrderedCollection new.
	afterLastAlloca := aFunction basicBlocks first firstInstruction.
	aFunction basicBlocks first allocaInstructionsDo: [ :ins |
		afterLastAlloca := ins nextInstruction.
		ins valueType isDynamicObjectType ifTrue: [
			objectVariables add: ins.
		].
	].

	returnInstructions := OrderedCollection new.

	aFunction basicBlocks do: [ :bb |
		bb instructionsDo: [ :ins |
			(ins isStore and: [ins value type isDynamicObjectType]) ifTrue: [
				self replaceStoreWithRefcountedWriteBarrier: ins
			].
	
			ins isInstantiateClosure ifTrue: [
				ins instructionReferences ifEmpty: [
					self halt.
				]
			].
					
			(ins type isDynamicObjectType and:
			[ins isMessageSend or:
			[ins isCall or:
			[ins isDynamicObjectNativeCast or:
			[ins isGetThisContext ]]]]) ifTrue: [
				ins instructionReferences ifEmpty: [
					self releaseValue: ins
				] ifNotEmpty: [
					objectVariables add: (self moveReference: ins intoTemporaryBefore: afterLastAlloca)
				]
			].

			(ins isReturn and: [ ins value type isDynamicObjectType ]) ifTrue: [ 
				self increaseReference: ins value beforeReturn: ins.
			].
		
			(ins isReturn or: [ ins isReturnVoid ]) ifTrue: [
				returnInstructions add: ins.
			].
		].
	].

	objectVariables ifEmpty: [
		^ self
	].

	"Never return?"
	returnInstructions ifEmpty: [ self halt ].
	
	builder := SLVMBuilder on: aFunction.
	cleanUpBlock := builder newBasicBlock: #referenceCleanUp.
	builder currentBlock: cleanUpBlock.

	returnValue := nil.
	aFunction functionType returnType isVoidType ifFalse: [
		returnInstructions size = 1 ifTrue: [
			returnValue := returnInstructions first value.
		] ifFalse: [
			returnValue := builder phi: aFunction functionType returnType.
			returnInstructions do: [ :ret | returnValue addValue: ret value from: ret block ]
		]
	].

	returnInstructions do: [ :ret |
		self replaceInstruction: ret with: (SLVMJump destination: cleanUpBlock).
	].

	objectVariables do: [ :var |
		builder call: releaseReference arguments: { builder load: var }
	].

	aFunction functionType returnType isVoidType ifTrue: [
		builder returnVoid
	] ifFalse: [
		builder return: returnValue
	].

]

{ #category : #applying }
SLVMFunctionGCLowtalkLoweringPass >> emitReadAndWriteBarriersOn: aFunction [
	aFunction basicBlocks do: [ :bb |
		bb instructionsDo: [ :ins |
			(ins isStore and: [ins value type isDynamicObjectType]) ifTrue: [
				self replaceStoreWithWriteBarrier: ins
			].
			(ins isLoad and: [ins value type isDynamicObjectType]) ifTrue: [
				self replaceLoadWithReadBarrier: ins
			].
		]
	]
]

{ #category : #'reference counting' }
SLVMFunctionGCLowtalkLoweringPass >> increaseReference: reference before: anInstruction [
	| newInstruction |
	newInstruction := SLVMCall function: increaseReference arguments: { reference }.
	anInstruction block add: newInstruction before: anInstruction

]

{ #category : #'reference counting' }
SLVMFunctionGCLowtalkLoweringPass >> increaseReference: reference beforeReturn: instruction [
	reference isInstruction ifTrue: [
		reference isBitCast ifTrue: [ ^ self ].
	].

	self increaseReference: reference before: instruction
]

{ #category : #'reference counting' }
SLVMFunctionGCLowtalkLoweringPass >> moveReference: ins intoTemporaryBefore: afterLastAlloca [
	"Create the temporary"
	| temporary |
	temporary := SLVMAlloca pointerSize: pointerSize valueType: ins type.
	afterLastAlloca block add: temporary before: afterLastAlloca.
					
	"Store the reference"
	ins block add:(SLVMCall function: writeBarrierNoIncrement arguments: { ins . temporary }) after: ins.
	^ temporary
]

{ #category : #applying }
SLVMFunctionGCLowtalkLoweringPass >> passOnFunction: aFunction [
	aFunction isEmpty ifTrue: [ ^ self ].
	
	
	pointerSize := aFunction compilationTarget pointerSize.
	
	objectModel := aFunction compilationTarget objectModel.
	readBarrier := objectModel readBarrier.
	writeBarrier := objectModel writeBarrier.
	writeBarrierNoIncrement := objectModel writeBarrierNoIncrement.
	increaseReference := objectModel increaseReference.
	releaseReference := objectModel releaseReference.

	self cleanInstructionsOf: aFunction.
	
	(increaseReference isNotNil and: [ releaseReference isNotNil ]) ifTrue: [
		self emitAutomaticReferenceCountingOn: aFunction
	] ifFalse: [
		self emitReadAndWriteBarriersOn: aFunction
	].

]

{ #category : #'reference counting' }
SLVMFunctionGCLowtalkLoweringPass >> releaseValue: anInstruction [
	| newInstruction |
	newInstruction := SLVMCall function: releaseReference arguments: { anInstruction }.
	anInstruction block add: newInstruction after: anInstruction
]

{ #category : #applying }
SLVMFunctionGCLowtalkLoweringPass >> replaceInstruction: instruction with: newInstruction [
	instruction block add: newInstruction before: instruction.
	instruction replaceWith: newInstruction.
	
	newInstruction isTerminator ifTrue: [
		newInstruction block computeSuccessors
	]
]

{ #category : #applying }
SLVMFunctionGCLowtalkLoweringPass >> replaceLoadWithReadBarrier: instruction [
	self replaceInstruction: instruction with: (SLVMCall function: readBarrier arguments: { instruction variable })

]

{ #category : #'reference counting' }
SLVMFunctionGCLowtalkLoweringPass >> replaceStoreWithRefcountedWriteBarrier: instruction [
	self replaceInstruction: instruction with: (SLVMCall function: writeBarrier arguments: { instruction value . instruction variable })
]

{ #category : #applying }
SLVMFunctionGCLowtalkLoweringPass >> replaceStoreWithWriteBarrier: instruction [
	self replaceInstruction: instruction with: (SLVMCall function: writeBarrier arguments: { instruction value . instruction variable })
]

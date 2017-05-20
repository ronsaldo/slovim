Class {
	#name : #SLVMOptDestroySSA,
	#superclass : #SLVMFunctionOptimizationPass,
	#instVars : [
		'phiAllocaDictionary'
	],
	#category : #'Slovim-Core-Optimizations'
}

{ #category : #adding }
SLVMOptDestroySSA >> addAllocaInstructionsTo: aFunction [
	| firstBlock pointerSize alloca |
	firstBlock := aFunction basicBlocks first.
	pointerSize := aFunction compilationTarget pointerSize.
	
	aFunction basicBlocks do: [ :basicBlock |
		basicBlock instructionsDo: [ :instruction |
			instruction isPhi ifTrue: [
				instruction instructionReferences ifEmpty: [
					instruction removeFromBlock
				] ifNotEmpty: [ 
					alloca := SLVMAlloca pointerSize: pointerSize valueType: instruction type.
					alloca name: instruction name.
				
					firstBlock addFirst: alloca.
					phiAllocaDictionary at: instruction put: alloca.
				]
			]
		]
	]
]

{ #category : #'as yet unclassified' }
SLVMOptDestroySSA >> insertPhiCopiesFrom: startBlock to: targetBlock before: branchInstruction [
	| conflictingVariables writtenVariables sourceVariable destinationVariable firstStore store load |
	conflictingVariables := IdentityDictionary new.
	firstStore := nil.
	writtenVariables := IdentitySet new.
	targetBlock phiInstructionsDo: [ :phiInstruction |
		sourceVariable := phiInstruction valueFromIncomingBlock: startBlock.
		sourceVariable ifNotNil: [
			sourceVariable isPhi ifTrue: [ 
				sourceVariable := phiAllocaDictionary at: sourceVariable
			].
		
			(writtenVariables includes: sourceVariable) ifTrue: [ 
				sourceVariable := conflictingVariables at: sourceVariable ifAbsentPut: [ 
					load := SLVMLoadInstruction variable: sourceVariable.
					load name: #phiLoad.
					startBlock add: load before: (firstStore ifNil: [ branchInstruction ]).
					load
				].
			].
		
			"Create the store."
			destinationVariable := phiAllocaDictionary at: phiInstruction.
			store := SLVMStoreInstruction value: sourceVariable variable: destinationVariable.
			store name: #phiCopy.
			startBlock add: store before: branchInstruction.

			"Mark the variable as written."
			firstStore ifNil: [ firstStore := store ].
			writtenVariables add: destinationVariable.
		].
	].

]

{ #category : #'as yet unclassified' }
SLVMOptDestroySSA >> passOnFunction: aFunction [
	aFunction isEmpty ifTrue: [ ^ self ].
	
	phiAllocaDictionary := IdentityDictionary new.
	self addAllocaInstructionsTo: aFunction.
	phiAllocaDictionary ifEmpty: [ ^ self ].

	self storeValuesAtEndOfBlocksOf: aFunction.
	self replacePhiWithLoadsIn: aFunction.

]

{ #category : #'as yet unclassified' }
SLVMOptDestroySSA >> replacePhiWithLoadsIn: aFunction [
	| load |
	phiAllocaDictionary keysAndValuesDo: [ :phi :alloca |
		load := SLVMLoadInstruction variable: alloca.
		load name: phi name.
		phi block add: load before: phi.
		phi replaceWith: load.
	]
]

{ #category : #'as yet unclassified' }
SLVMOptDestroySSA >> splitBranch: branchInstruction [
	self halt.
]

{ #category : #'as yet unclassified' }
SLVMOptDestroySSA >> storeValuesAtEndOfBlock: basicBlock [
	| branchInstruction |
	basicBlock successors ifEmpty: [ ^self ].
	branchInstruction := basicBlock lastInstruction.
	branchInstruction isBranch ifTrue: [
		(branchInstruction trueBlock hasPhiInstructions or: [ branchInstruction falseBlock hasPhiInstructions ]) ifTrue: [ 
			self splitBranch: branchInstruction
		]
	] ifFalse: [
		self assert: branchInstruction isJump.
		branchInstruction destination hasPhiInstructions ifTrue: [
			self insertPhiCopiesFrom: basicBlock to: branchInstruction destination before: branchInstruction
		]
	]

]

{ #category : #'as yet unclassified' }
SLVMOptDestroySSA >> storeValuesAtEndOfBlocksOf: aFunction [
	aFunction basicBlocks do: [ :basicBlock |
		self storeValuesAtEndOfBlock: basicBlock
	]
]

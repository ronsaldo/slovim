"
I represent an instruction in single static assignment form.
"
Class {
	#name : #SLVMInstruction,
	#superclass : #SLVMFunctionLocalValue,
	#instVars : [
		'block',
		'parameters',
		'previousInstruction',
		'nextInstruction',
		'livenessIndex'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #enumerating }
SLVMInstruction >> allInstructionsDo: aBlock [
	aBlock value: self
]

{ #category : #'as yet unclassified' }
SLVMInstruction >> applySubstitutions: substitutionDictionary [
	parameters doWithIndex: [ :param :index |
		substitutionDictionary at: param ifPresent: [ :substitution |
			parameters at: index put: substitution.
			substitution addInstructionReference: self
		]
	]
]

{ #category : #printing }
SLVMInstruction >> asFullSExpression [
	^ { name . self mnemonic . self type asSExpression . self flags sorted .
		parameters collect: [ :each | each asSExpression ] as: Array.
	} , (self extraParametersSExpression ifNil: [#()] ifNotNil: [:params | {params} ])
]

{ #category : #accessing }
SLVMInstruction >> block [
	^ block
]

{ #category : #accessing }
SLVMInstruction >> block: anObject [
	block := anObject.
	self function: (block ifNotNil: [ block function])
]

{ #category : #accessing }
SLVMInstruction >> dominates: anotherInstruction [
	block ~~ anotherInstruction block ifTrue: [
		^ block dominates: anotherInstruction block
	].

	^ block isInstruction: self beforeThan: anotherInstruction
]

{ #category : #printing }
SLVMInstruction >> extraParametersSExpression [
	^ nil
]

{ #category : #'basic optimizations' }
SLVMInstruction >> foldConstant [
	^ self
]

{ #category : #printing }
SLVMInstruction >> fullPrintOn: aStream [
	self type isVoidType ifFalse: [
		self printOn: aStream.
		aStream nextPutAll: ' = '.
	].
	aStream putKeyword: self mnemonic; space.
	parameters doWithIndex: [ :param :index |
		index > 1 ifTrue: [  aStream nextPutAll: ', ' ].
		aStream print: param
	]
]

{ #category : #testing }
SLVMInstruction >> hasInputs [
	^ parameters isNotEmpty
]

{ #category : #testing }
SLVMInstruction >> hasOutputs [
	^ true
]

{ #category : #initialization }
SLVMInstruction >> initialize [
	super initialize.
	parameters := #().
]

{ #category : #testing }
SLVMInstruction >> isAlloca [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isBinaryComparison [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isBinaryOperation [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isBitCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isBoolToDynamicObjectCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isBranch [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isCall [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isCharToDynamicObjectCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isDebugInstruction [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isDynamicObjectNativeCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isDynamicObjectReferenceCreator [
	"I should answer true in instructions that require an implicit release reference"
	^ false
]

{ #category : #testing }
SLVMInstruction >> isDynamicObjectToBoolCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isDynamicObjectToCharCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isDynamicObjectToFloatCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isDynamicObjectToIntCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isExtractValue [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isExtractVectorElement [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isFloatToDynamicObjectCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isFloatToIntCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isFloatingPointCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isGetElementPointer [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isGetExceptionSelectorFromTypeInfo [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isGetThisContext [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isInsertValue [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isInsertVectorElement [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isInstantiateClosure [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isInstruction [
	^ true
]

{ #category : #testing }
SLVMInstruction >> isIntToDynamicObjectCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isIntToFloatCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isIntToPointerCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isInvoke [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isJump [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isLoad [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isMakeMatrix [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isMakeVector [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isMessageSend [
	^ true
]

{ #category : #testing }
SLVMInstruction >> isPointerToIntCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isPureInstruction [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isResumeException [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isReturn [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isReturnFromContext [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isReturnVoid [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isReturnVoidFromContext [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isShuffleVectors [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isSignExtend [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isStore [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isSwitch [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isTerminator [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isTruncate [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isUnreachable [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isZeroExtend [
	^ false
]

{ #category : #accessing }
SLVMInstruction >> livenessIndex [
	^ livenessIndex
]

{ #category : #accessing }
SLVMInstruction >> livenessIndex: anObject [
	livenessIndex := anObject
]

{ #category : #accessing }
SLVMInstruction >> nextInstruction [
	^ nextInstruction
]

{ #category : #accessing }
SLVMInstruction >> nextInstruction: anObject [
	nextInstruction := anObject
]

{ #category : #accessing }
SLVMInstruction >> nextNonDebugInstruction [
	(nextInstruction isNotNil and: [ nextInstruction isDebugInstruction ]) ifTrue: [ 
		^ nextInstruction nextNonDebugInstruction
	].
	^ nextInstruction
]

{ #category : #enumerating }
SLVMInstruction >> notVisitedParameters: visitedElements recursivelyDo: aBlock [
	parameters do: [ :param |
		(visitedElements includes: param) ifFalse: [
			visitedElements add: param.
			aBlock value: param.
			param notVisitedParameters: visitedElements recursivelyDo: aBlock
		]
	]
]

{ #category : #accessing }
SLVMInstruction >> parameters [
	^ parameters
]

{ #category : #accessing }
SLVMInstruction >> parameters: anArrayOfParameter [
	parameters := anArrayOfParameter.
	parameters do: [ :param | param addInstructionReference: self ]
]

{ #category : #copying }
SLVMInstruction >> postCopy [
	super postCopy.
	parameters := parameters copy.
	block := nil.	
	previousInstruction := nil.
	nextInstruction := nil.
]

{ #category : #accessing }
SLVMInstruction >> previousInstruction [
	^ previousInstruction
]

{ #category : #accessing }
SLVMInstruction >> previousInstruction: anObject [
	previousInstruction := anObject
]

{ #category : #modifying }
SLVMInstruction >> removeFromBlock [
	self assert: instructionReferences isEmpty.
	parameters do: [ :param | param removeInstructionReference: self ].
	block remove: self.
]

{ #category : #modifying }
SLVMInstruction >> removeFromBlockWithAllReferences [
	instructionReferences copy do: [:each | each removeFromBlockWithAllReferences].
	self removeFromBlock
]

{ #category : #modifying }
SLVMInstruction >> replaceReferencesWith: aNewInstruction [
	self == aNewInstruction ifTrue: [ ^ self ].
	
	instructionReferences do: [ :usage |
		usage parameters replaceAll: self with: aNewInstruction.
		aNewInstruction addInstructionReference: usage.
	].

	instructionReferences removeAll.

]

{ #category : #modifying }
SLVMInstruction >> replaceWith: aNewInstruction [
	self == aNewInstruction ifTrue: [ ^ self ].
	
	self replaceReferencesWith: aNewInstruction.
	self removeFromBlock
]

{ #category : #modifying }
SLVMInstruction >> replaceWithNewInstruction: aNewInstruction [
	block add: aNewInstruction before: self.
	aNewInstruction name: name.
	^ self replaceWith: aNewInstruction
]

{ #category : #accessing }
SLVMInstruction >> signature [
	^ {self class . self type . parameters}
]

{ #category : #'as yet unclassified' }
SLVMInstruction >> splitBasicBlock [
	| nextBlock nextChain |
	nextBlock := SLVMBasicBlock new name: (block name ifNotNil: [:blockName | (blockName , '_split') asSymbol]).
	block function addBasicBlock: nextBlock.
	
	"Update the phis"
	block successors do: [ :succ |
		succ phiInstructionsDo: [ :phi |
			phi replaceParent: block with: nextBlock
		]
	].

	"Unlink the next instructions"
	nextChain := self nextInstruction.
	
	block removeChain: nextChain.
	self assert: nextChain previousInstruction isNil.
	self assert: nextInstruction isNil.
	
	nextBlock setChain: nextChain.
	block computeSuccessors.
	nextBlock isLastTerminator ifTrue: [
		nextBlock computeSuccessors.
		nextBlock successors do: #predecessorsCouldBeRemoved
	].
	^ nextBlock
]

{ #category : #accessing }
SLVMInstruction >> successors [
	^ #()
]

{ #category : #testing }
SLVMInstruction >> validateInBlock: aBasicBlock [
	self assert: block == aBasicBlock
]

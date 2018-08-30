"
I represent an instruction in single static assignment form.
"
Class {
	#name : #SLVMInstruction,
	#superclass : #SLVMFunctionLocalValue,
	#instVars : [
		'name',
		'block',
		'parameters',
		'previousInstruction',
		'nextInstruction',
		'livenessIndex'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #adding }
SLVMInstruction >> addUnreachableSuccessors [
	"This is used by branching instructions"
]

{ #category : #enumerating }
SLVMInstruction >> allInstructionsDo: aBlock [
	aBlock value: self
]

{ #category : #enumerating }
SLVMInstruction >> allParametersDo: aBlock [
	parameters do: [ :param | param withAllParametersDo: aBlock ]
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

{ #category : #accessing }
SLVMInstruction >> block [
	^ block
]

{ #category : #accessing }
SLVMInstruction >> block: anObject [
	block := anObject
]

{ #category : #accessing }
SLVMInstruction >> dominates: anotherInstruction [
	block ~~ anotherInstruction block ifTrue: [
		^ block dominates: anotherInstruction block
	].

	^ block isInstruction: self beforeThan: anotherInstruction
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

{ #category : #accessing }
SLVMInstruction >> function [
	^ self block function
]

{ #category : #testing }
SLVMInstruction >> hasAnonName [
	^ name isNil or: [ name detect: [:c | c isDigit not] ifFound: [false] ifNone: [ true ] ]
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
SLVMInstruction >> isBitCast [
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
SLVMInstruction >> isDynamicObjectNativeCast [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isDynamicObjectReferenceCreator [
	"I should answer true in instructions that require an implicit release reference"
	^ false
]

{ #category : #testing }
SLVMInstruction >> isExtractValue [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isGetElementPointer [
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
SLVMInstruction >> isInstantiateClosure [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isInstruction [
	^ true
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
SLVMInstruction >> isMessageSend [
	^ true
]

{ #category : #testing }
SLVMInstruction >> isPureInstruction [
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
SLVMInstruction >> isStore [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isTerminator [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isUnreachable [
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

{ #category : #printing }
SLVMInstruction >> mnemonic [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMInstruction >> name [
	^ name
]

{ #category : #accessing }
SLVMInstruction >> name: anObject [
	name := anObject
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

{ #category : #printing }
SLVMInstruction >> printOn: aStream [
	aStream nextPut: $%; nextPutAll: self validName
]

{ #category : #modifying }
SLVMInstruction >> removeFromBlock [
	self assert: instructionReferences isEmpty.
	parameters do: [ :param | param removeInstructionReference: self ].
	block remove: self.
]

{ #category : #modifying }
SLVMInstruction >> removeFromBlockWithAllReferences [
	instructionReferences copy do: #removeFromBlockWithAllReferences.
	self removeFromBlock
]

{ #category : #modifying }
SLVMInstruction >> replaceWith: aNewInstruction [
	self == aNewInstruction ifTrue: [ ^ self ].
	
	instructionReferences do: [ :usage |
		usage parameters replaceAll: self with: aNewInstruction.
		aNewInstruction addInstructionReference: usage.
	].

	instructionReferences removeAll.
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
	nextBlock := SLVMBasicBlock new name: (block name , '_split').
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

{ #category : #accessing }
SLVMInstruction >> validName [
	^ name ifNil: [ #anon ]
]

{ #category : #testing }
SLVMInstruction >> validateInBlock: aBasicBlock [
	self assert: block == aBasicBlock
]

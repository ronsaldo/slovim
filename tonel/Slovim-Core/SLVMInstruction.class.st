Class {
	#name : #SLVMInstruction,
	#superclass : #SLVMValue,
	#instVars : [
		'name',
		'block',
		'parameters',
		'instructionReferences',
		'previousInstruction',
		'nextInstruction',
		'livenessIndex'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #adding }
SLVMInstruction >> addInstructionReference: anInstruction [
	instructionReferences add: anInstruction
]

{ #category : #adding }
SLVMInstruction >> addUnreachableSuccessors [
	"This is used by branching instructions"
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
	aStream nextPutAll: self mnemonic; space.
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

{ #category : #testing }
SLVMInstruction >> hasReferences [
	^ instructionReferences isNotEmpty
]

{ #category : #initialization }
SLVMInstruction >> initialize [
	instructionReferences := OrderedCollection new.
	parameters := #().
]

{ #category : #accessing }
SLVMInstruction >> instructionReferences [
	^ instructionReferences
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
SLVMInstruction >> isBranch [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isCall [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isGetElementPointer [
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
SLVMInstruction >> isPureInstruction [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isReturn [
	^ false
]

{ #category : #testing }
SLVMInstruction >> isReturnVoid [
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
	parameters := parameters copy.
	instructionReferences := OrderedCollection new.
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
	aStream nextPut: $%; nextPutAll: name
]

{ #category : #modifying }
SLVMInstruction >> removeFromBlock [
	self assert: instructionReferences isEmpty.
	parameters do: [ :param | param removeInstructionReference: self ].
	block remove: self.
]

{ #category : #adding }
SLVMInstruction >> removeInstructionReference: anInstruction [
	instructionReferences removeAllSuchThat: [:el | el == anInstruction]
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
		
	^ nextBlock
]

{ #category : #accessing }
SLVMInstruction >> successors [
	^ #()
]

Class {
	#name : #SLVMInstruction,
	#superclass : #SLVMValue,
	#instVars : [
		'name',
		'block',
		'parameters',
		'instructionReferences'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #adding }
SLVMInstruction >> addInstructionReference: anInstruction [
	instructionReferences add: anInstruction
]

{ #category : #accessing }
SLVMInstruction >> block [
	^ block
]

{ #category : #accessing }
SLVMInstruction >> block: anObject [
	block := anObject
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

{ #category : #initialization }
SLVMInstruction >> initialize [
	instructionReferences := IdentitySet new.
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
SLVMInstruction >> isBranch [
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
SLVMInstruction >> parameters [
	^ parameters
]

{ #category : #accessing }
SLVMInstruction >> parameters: anArrayOfParameter [
	parameters := anArrayOfParameter.
	parameters do: [ :param | param addInstructionReference: self ]
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
	instructionReferences remove: anInstruction
]

{ #category : #modifying }
SLVMInstruction >> replaceWith: aNewInstruction [
	instructionReferences do: [ :usage |
		usage parameters replaceAll: self with: aNewInstruction.
		aNewInstruction addInstructionReference: usage.
	].

	instructionReferences removeAll.
	self removeFromBlock
]

{ #category : #accessing }
SLVMInstruction >> successors [
	^ #()
]

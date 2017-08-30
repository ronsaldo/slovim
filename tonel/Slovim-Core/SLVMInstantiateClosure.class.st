Class {
	#name : #SLVMInstantiateClosure,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'closureType'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMInstantiateClosure class >> definition: definition captures: captures [
	^ self new definition: definition captures: captures
]

{ #category : #printing }
SLVMInstantiateClosure >> accept: aVisitor [
	^ aVisitor visitInstantiateClosure: self
]

{ #category : #enumerating }
SLVMInstantiateClosure >> allInstructionsDo: aBlock [
	aBlock value: self.
	self definition allInstructionsDo: aBlock
]

{ #category : #accessing }
SLVMInstantiateClosure >> captures [
	^ parameters allButFirst
]

{ #category : #accessing }
SLVMInstantiateClosure >> childrenNodes [
	^ { self definition }
]

{ #category : #accessing }
SLVMInstantiateClosure >> definition [
	^ parameters first
]

{ #category : #construction }
SLVMInstantiateClosure >> definition: definition captures: captures [
	| functionType captureTypes |
	self parameters: { definition } , captures.
	self assert: definition isClosureDefinition.
	self assert: captures size = definition captures size.
	1 to: captures size do: [ :i | self assert: (captures at: i) type = (definition captures at: i) type].
	
	functionType := definition functionType.
	captureTypes := captures collect: #type.
	closureType := definition closureType.
	type := SLVMPointerType size: (definition compilationTarget pointerSize) baseType: closureType storage: SLVMType genericStorage.

]

{ #category : #testing }
SLVMInstantiateClosure >> isInstantiateClosure [
	^ true
]

{ #category : #printing }
SLVMInstantiateClosure >> mnemonic [
	^ 'instantiateClosure'
]

{ #category : #accessing }
SLVMInstantiateClosure >> type [
	^ type
]

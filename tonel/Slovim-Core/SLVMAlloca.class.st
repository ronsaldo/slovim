Class {
	#name : #SLVMAlloca,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'valueType'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMAlloca class >> valueType: valueType [
	^ self new valueType: valueType
]

{ #category : #visitor }
SLVMAlloca >> accept: aVisitor [
	^ aVisitor visitAlloca: self
]

{ #category : #printing }
SLVMAlloca >> fullPrintOn: aStream [
	self printOn: aStream.
	aStream nextPutAll: ' = alloca ';
		print: type
]

{ #category : #testing }
SLVMAlloca >> isAlloca [
	^ true
]

{ #category : #printing }
SLVMAlloca >> mnemonic [
	^ 'alloca'
]

{ #category : #accessing }
SLVMAlloca >> type [
	^ type
]

{ #category : #accessing }
SLVMAlloca >> valueType [
	^ valueType
]

{ #category : #accessing }
SLVMAlloca >> valueType: aType [
	self assert: aType isSlovimType.
	valueType := aType.
	type := SLVMReferenceType baseType: valueType storage: SLVMType functionStorage
]

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
SLVMAlloca class >> pointerSize: pointerSize valueType: valueType [
	^ self new pointerSize: pointerSize valueType: valueType
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
SLVMAlloca >> pointerSize: pointerSize valueType: aType [
	self assert: aType isSlovimType.
	valueType := aType.
	type := SLVMPointerType size: pointerSize baseType: valueType storage: SLVMType functionStorage
]

{ #category : #accessing }
SLVMAlloca >> type [
	^ type
]

{ #category : #accessing }
SLVMAlloca >> valueType [
	^ valueType
]

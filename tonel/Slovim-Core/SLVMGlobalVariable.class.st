Class {
	#name : #SLVMGlobalVariable,
	#superclass : #SLVMGlobalValue,
	#instVars : [
		'valueType',
		'type',
		'initialValue',
		'readOnly'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMGlobalVariable class >> module: module name: varName valueType: valueType storage: storage [
	| var |
	var := self pointerSize: module compilationTarget pointerSize name: varName valueType: valueType  storage: storage.
	module add: var.
	^ var
]

{ #category : #construction }
SLVMGlobalVariable class >> pointerSize: pointerSize name: aString valueType: aFunctionType storage: storageClass [
	^ self new name: aString; pointerSize: pointerSize valueType: aFunctionType storage: storageClass; yourself
]

{ #category : #visitor }
SLVMGlobalVariable >> accept: aVisitor [
	^ aVisitor visitGlobalVariable: self
]

{ #category : #printing }
SLVMGlobalVariable >> fullPrintOn: aStream [
	aStream nextPutAll: 'global @'; print: type; space; nextPutAll: name; space.
	self printPropertiesOn: aStream.
	aStream cr
]

{ #category : #accessing }
SLVMGlobalVariable >> initialValue [
	^ initialValue
]

{ #category : #accessing }
SLVMGlobalVariable >> initialValue: anObject [
	initialValue := anObject
]

{ #category : #initialization }
SLVMGlobalVariable >> initialize [
	super initialize.
	readOnly := false.
]

{ #category : #testing }
SLVMGlobalVariable >> isGlobalVariable [
	^ true
]

{ #category : #accessing }
SLVMGlobalVariable >> pointerSize: pointerSize valueType: aType storage: storageClass [
	self assert: aType isSlovimType.
	valueType := aType.
	type := SLVMPointerType size: pointerSize baseType: valueType storage: storageClass.
]

{ #category : #accessing }
SLVMGlobalVariable >> readOnly [
	^ readOnly
]

{ #category : #accessing }
SLVMGlobalVariable >> readOnly: anObject [
	readOnly := anObject
]

{ #category : #accessing }
SLVMGlobalVariable >> type [
	^ type
]

{ #category : #accessing }
SLVMGlobalVariable >> valueType [
	^ valueType
]

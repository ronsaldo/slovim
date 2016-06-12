Class {
	#name : #SLVMGlobalVariable,
	#superclass : #SLVMGlobalValue,
	#instVars : [
		'valueType',
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMGlobalVariable class >> name: aString valueType: aFunctionType storage: storageClass [
	^ self new name: aString; valueType: aFunctionType storage: storageClass; yourself
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

{ #category : #testing }
SLVMGlobalVariable >> isGlobalVariable [
	^ true
]

{ #category : #accessing }
SLVMGlobalVariable >> type [
	^ type
]

{ #category : #accessing }
SLVMGlobalVariable >> valueType [
	^ valueType
]

{ #category : #accessing }
SLVMGlobalVariable >> valueType: aType storage: storageClass [
	self assert: aType isSlovimType.
	valueType := aType.
	type := SLVMReferenceType baseType: valueType storage: storageClass.
]

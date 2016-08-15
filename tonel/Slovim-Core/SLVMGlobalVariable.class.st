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

{ #category : #accessing }
SLVMGlobalVariable >> initialValue [
	^ initialValue
]

{ #category : #accessing }
SLVMGlobalVariable >> initialValue: anObject [
	initialValue := anObject
]

{ #category : #'as yet unclassified' }
SLVMGlobalVariable >> initialize [
	super initialize.
	readOnly := false.
]

{ #category : #testing }
SLVMGlobalVariable >> isGlobalVariable [
	^ true
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

{ #category : #accessing }
SLVMGlobalVariable >> valueType: aType storage: storageClass [
	self assert: aType isSlovimType.
	valueType := aType.
	type := SLVMReferenceType baseType: valueType storage: storageClass.
]

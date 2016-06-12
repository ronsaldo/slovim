Class {
	#name : #SLVMFunctionType,
	#superclass : #SLVMType,
	#instVars : [
		'arguments',
		'returnType'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #construction }
SLVMFunctionType class >> arguments: argumentTypes returnType: returnType [
	^ self new arguments: argumentTypes; returnType: returnType; yourself
]

{ #category : #comparing }
SLVMFunctionType >> = other [
	^ self class == other class and: [ arguments = other arguments and: [ returnType = other returnType  ] ]
]

{ #category : #visitor }
SLVMFunctionType >> accept: aVisitor [
	^ aVisitor visitFunctionType: self
]

{ #category : #accessing }
SLVMFunctionType >> arguments [
	^ arguments
]

{ #category : #accessing }
SLVMFunctionType >> arguments: aCollection [
	aCollection do: [:arg | self assert: arg isSlovimType].
	arguments := aCollection.
	
]

{ #category : #comparing }
SLVMFunctionType >> hash [
	^ (self class hash bitXor: arguments hash) bitXor: returnType hash
]

{ #category : #testing }
SLVMFunctionType >> isFunctionType [
	^ true
]

{ #category : #printing }
SLVMFunctionType >> printOn: aStream [
	aStream nextPutAll: 'function {('.
	arguments doWithIndex: [ :arg :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: arg.
	].
	aStream nextPutAll: ') ->';
		print: returnType;
		nextPutAll:  '}'
]

{ #category : #accessing }
SLVMFunctionType >> returnType [
	^ returnType
]

{ #category : #accessing }
SLVMFunctionType >> returnType: aType [
	self assert: aType isSlovimType.
	returnType := aType
]

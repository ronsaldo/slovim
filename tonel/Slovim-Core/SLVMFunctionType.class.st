Class {
	#name : #SLVMFunctionType,
	#superclass : #SLVMType,
	#instVars : [
		'callingConvention',
		'arguments',
		'returnType',
		'variadic'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #construction }
SLVMFunctionType class >> arguments: argumentTypes returnType: returnType [
	^ self callingConvention: self genericCallingConvention arguments: argumentTypes returnType: returnType
]

{ #category : #construction }
SLVMFunctionType class >> callingConvention: callingConvention arguments: argumentTypes returnType: returnType [
	^ self new callingConvention: callingConvention; arguments: argumentTypes; returnType: returnType; yourself
]

{ #category : #'calling conventions' }
SLVMFunctionType class >> cdeclCallingConvention [
	^ #cdecl
]

{ #category : #'calling conventions' }
SLVMFunctionType class >> genericCallingConvention [
	^ self cdeclCallingConvention
]

{ #category : #'calling conventions' }
SLVMFunctionType class >> smalltalkCallingConvention [
	^ #smalltalk
]

{ #category : #'calling conventions' }
SLVMFunctionType class >> stdcallCallingConvention [
	^ #stdcall
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

{ #category : #accessing }
SLVMFunctionType >> callingConvention [
	^ callingConvention
]

{ #category : #accessing }
SLVMFunctionType >> callingConvention: anObject [
	callingConvention := anObject
]

{ #category : #comparing }
SLVMFunctionType >> hash [
	^ (self class hash bitXor: arguments hash) bitXor: returnType hash
]

{ #category : #initialization }
SLVMFunctionType >> initialize [
	super initialize.
	variadic := false.
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

{ #category : #accessing }
SLVMFunctionType >> variadic [
	^ variadic
]

{ #category : #accessing }
SLVMFunctionType >> variadic: anObject [
	variadic := anObject
]

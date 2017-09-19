Class {
	#name : #SLVMFunctionType,
	#superclass : #SLVMType,
	#instVars : [
		'callingConvention',
		'arguments',
		'returnType',
		'variadic',
		'argumentAttributes'
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
SLVMFunctionType >> argumentAt: argumentIndex addAttribute: attribute [
	| attributes |
	attributes := argumentAttributes at: argumentIndex.
	(attributes includes: attribute) ifFalse: [
		argumentAttributes at: argumentIndex put: (attributes copyWith: attribute)
	]
]

{ #category : #accessing }
SLVMFunctionType >> argumentAt: argumentIndex hasAttribute: attribute [
	| attributes |
	attributes := argumentAttributes at: argumentIndex.
	^ attributes includes: attribute
]

{ #category : #'as yet unclassified' }
SLVMFunctionType >> argumentDescriptorFlags [
	(#(smalltalk smalltalk_send smalltalk_supersend) includes: callingConvention) ifTrue: [ 
		^ 0
	].
	
	^ 1<<29
]

{ #category : #accessing }
SLVMFunctionType >> arguments [
	^ arguments
]

{ #category : #accessing }
SLVMFunctionType >> arguments: aCollection [
	aCollection do: [:arg | self assert: arg isSlovimType].
	arguments := aCollection.
	argumentAttributes := (Array new: arguments size) atAllPut: #().
	
]

{ #category : #'as yet unclassified' }
SLVMFunctionType >> argumentsDescriptorWithTarget: aCompilationTarget [
	| dynObjectCount nativeArgumentSize nativeArgumentAlignment |
	dynObjectCount := 0.
	nativeArgumentSize := 0.
	nativeArgumentAlignment := aCompilationTarget pointerSize.
	arguments doWithIndex: [:arg :index |
		(arg isDynamicObjectType or: [self argumentAt: index hasAttribute: #dynobject]) ifTrue: [ 
			dynObjectCount := dynObjectCount + 1.
		] ifFalse: [ 
			nativeArgumentSize := nativeArgumentSize alignedTo: (arg alignment max: aCompilationTarget pointerSize).
			nativeArgumentAlignment := nativeArgumentAlignment max: arg alignment
		]
	].

	^ dynObjectCount | (nativeArgumentSize << 8) | (((nativeArgumentAlignment highBit - aCompilationTarget pointerSize highBit) max: 0) << 24) | self argumentDescriptorFlags
]

{ #category : #accessing }
SLVMFunctionType >> callingConvention [
	^ callingConvention
]

{ #category : #accessing }
SLVMFunctionType >> callingConvention: anObject [
	callingConvention := anObject
]

{ #category : #initialization }
SLVMFunctionType >> initialize [
	super initialize.
	variadic := false.
]

{ #category : #comparing }
SLVMFunctionType >> internalHash [	
	^ (self class hash bitXor: arguments hash) bitXor: returnType hash

]

{ #category : #testing }
SLVMFunctionType >> isFunctionType [
	^ true
]

{ #category : #printing }
SLVMFunctionType >> printOn: aStream [
	aStream nextPutAll: 'function '; print: callingConvention; nextPutAll:'{('.
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

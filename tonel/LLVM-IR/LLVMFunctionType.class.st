Class {
	#name : #LLVMFunctionType,
	#superclass : #LLVMType,
	#instVars : [
		'returnType',
		'params',
		'isVarArg'
	],
	#category : #'LLVM-IR'
}

{ #category : #'as yet unclassified' }
LLVMFunctionType class >> get: returnType params: params isVarArg: isVarArg [
	^ returnType context typeAt: { self . returnType . params . isVarArg }
		ifAbsentPut: [ self new
				context: returnType context;
				returnType: returnType;
				params: params;
				isVarArg: isVarArg;
				yourself ]
]

{ #category : #accessing }
LLVMFunctionType >> createName [
	^ ByteString streamContents: [ :out |
		out print: returnType; nextPutAll: ' ('.
		params doWithIndex: [ :param :index |
			index > 1 ifTrue: [
				out nextPutAll: ', '
			].
			out print: param.
		].
	
		isVarArg ifTrue: [ 
			params ifNotEmpty: [ out nextPutAll: ', ...' ] ifEmpty: [ out nextPutAll: '...' ]
		].
	
		out nextPutAll: ')'
	]
]

{ #category : #testing }
LLVMFunctionType >> isFunctionTy [
	^ true
]

{ #category : #accessing }
LLVMFunctionType >> isVarArg [
	^ isVarArg
]

{ #category : #accessing }
LLVMFunctionType >> isVarArg: anObject [
	isVarArg := anObject
]

{ #category : #'as yet unclassified' }
LLVMFunctionType >> name [
	^ name ifNil: [ name := self createName ]
]

{ #category : #accessing }
LLVMFunctionType >> params [
	^ params
]

{ #category : #accessing }
LLVMFunctionType >> params: anObject [
	params := anObject
]

{ #category : #accessing }
LLVMFunctionType >> returnType [
	^ returnType
]

{ #category : #accessing }
LLVMFunctionType >> returnType: anObject [
	returnType := anObject
]

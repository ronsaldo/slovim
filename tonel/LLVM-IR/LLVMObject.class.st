Class {
	#name : #LLVMObject,
	#superclass : #Object,
	#instVars : [
		'handle'
	],
	#pools : [
		'LLVMCConstants'
	],
	#category : #'LLVM-IR-Object'
}

{ #category : #'as yet unclassified' }
LLVMObject class >> enumDefine: list [
	| varName |
	list do: [ :element |
		varName := element first.
		(self hasClassVarNamed: varName) ifFalse: [ 
			self addClassVarNamed: varName
		].
		self classVarNamed: varName put: element
	].
]

{ #category : #accessing }
LLVMObject >> buildHandle [
	self subclassResponsibility
]

{ #category : #accessing }
LLVMObject >> handle [

	^ handle
]

{ #category : #accessing }
LLVMObject >> setHandle: anObject [

	handle := anObject
]

{ #category : #accessing }
LLVMObject >> validHandle [
	^ handle ifNil: [
		self buildHandle.
		handle
	]
]

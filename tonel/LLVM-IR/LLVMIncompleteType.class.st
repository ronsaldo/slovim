Class {
	#name : #LLVMIncompleteType,
	#superclass : #LLVMType,
	#instVars : [
		'definition'
	],
	#category : #'LLVM-IR-Types'
}

{ #category : #accessing }
LLVMIncompleteType >> buildHandle [
	self shouldNotImplement
]

{ #category : #accessing }
LLVMIncompleteType >> definition [
	^ definition
]

{ #category : #accessing }
LLVMIncompleteType >> definition: anObject [
	definition := anObject
]

{ #category : #accessing }
LLVMIncompleteType >> name [
	^ definition name
]

{ #category : #accessing }
LLVMIncompleteType >> validHandle [
	^ definition validHandle
]

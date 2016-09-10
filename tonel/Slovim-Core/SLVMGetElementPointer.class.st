Class {
	#name : #SLVMGetElementPointer,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMGetElementPointer class >> pointer: reference indices: index [
	^ self new pointer: reference indices: index
]

{ #category : #visitor }
SLVMGetElementPointer >> accept: aVisitor [
	^ aVisitor visitGetElementPointer: self
]

{ #category : #accessing }
SLVMGetElementPointer >> index [
	^ parameters second
]

{ #category : #printing }
SLVMGetElementPointer >> mnemonic [
	^ 'getElementPointer'
]

{ #category : #accessing }
SLVMGetElementPointer >> pointer [
	^ parameters first
]

{ #category : #construction }
SLVMGetElementPointer >> pointer: pointer indices: indices [
	self parameters: { pointer } , indices.
	self assert: (pointer type isPointerType or: [pointer type isDynamicObjectType ]).
	type := pointer type.
	indices doWithIndex: [ :index :depth |
		type := type pointerTypeOfMemberAt: index depth: depth.
	].

	 
]

{ #category : #accessing }
SLVMGetElementPointer >> type [
	^ type
]

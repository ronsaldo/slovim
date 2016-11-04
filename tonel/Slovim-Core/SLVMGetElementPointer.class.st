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
SLVMGetElementPointer >> indices [
	^ parameters allButFirst
]

{ #category : #testing }
SLVMGetElementPointer >> isElementAccess [
	^ parameters second isConstantValue and: [ parameters second value = 0 ]
]

{ #category : #testing }
SLVMGetElementPointer >> isGetElementPointer [
	^ true
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
		type := type pointerSize: pointer type size typeOfMemberAt: index depth: depth - 1.
	].

]

{ #category : #construction }
SLVMGetElementPointer >> strides [
	| pointerType pointerSize |
	pointerType := self pointer type.
	pointerSize := pointerType size.
	
	^ self indices collectWithIndex: [ :index :depth |
		pointerType := pointerType pointerSize: pointerSize typeOfMemberAt: index depth: depth - 1.
		pointerType elementStrideDepth: depth - 1
	].

]

{ #category : #accessing }
SLVMGetElementPointer >> type [
	^ type
]

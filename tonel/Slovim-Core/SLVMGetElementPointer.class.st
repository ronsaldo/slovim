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

{ #category : #testing }
SLVMGetElementPointer >> hasConstantIndices [
	self indices do: [ :index | index isConstantValue ifFalse: [^ false] ].
	^ true
]

{ #category : #accessing }
SLVMGetElementPointer >> indices [
	^ parameters allButFirst
]

{ #category : #construction }
SLVMGetElementPointer >> indicesWithStrides [
	| elementType stride offset |
	elementType := self pointer type.
	
	^ self indices collect: [ :index |
		stride := elementType strideWithIndex: index.
		offset := elementType offsetWithIndex: index.
		elementType := elementType typeOfMemberAt: index.
		{ index . stride . offset }
	].

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
	| pointerType memberType |
	self parameters: { pointer } , indices.
	self assert: (pointer type isPointerType or: [pointer type isDynamicObjectType ]).
	pointerType := pointer type.
	memberType := pointerType.
	indices do: [ :index |
		memberType := memberType typeOfMemberAt: index
	].

	type := SLVMPointerType size: pointerType size baseType: memberType storage: pointerType storage

]

{ #category : #accessing }
SLVMGetElementPointer >> type [
	^ type
]

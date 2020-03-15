Class {
	#name : #SLVMConstantExpresionGetElementPointer,
	#superclass : #SLVMConstantExpresion,
	#instVars : [
		'inBounds'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #testing }
SLVMConstantExpresionGetElementPointer class >> isAbstract [
	^ self == SLVMConstantExpresionGetElementPointer
]

{ #category : #printing }
SLVMConstantExpresionGetElementPointer class >> mnemonic [
	^ #constExprGEP
]

{ #category : #construction }
SLVMConstantExpresionGetElementPointer class >> pointer: reference indices: index [
	^ self new pointer: reference indices: index
]

{ #category : #accessing }
SLVMConstantExpresionGetElementPointer >> accept: aVisitor [
	^ aVisitor visitConstantExpressionGetElementPointer: self
]

{ #category : #accessing }
SLVMConstantExpresionGetElementPointer >> inBounds [
	^ inBounds
]

{ #category : #accessing }
SLVMConstantExpresionGetElementPointer >> inBounds: anObject [
	inBounds := anObject
]

{ #category : #printing }
SLVMConstantExpresionGetElementPointer >> indices [
	^ parameters allButFirst
]

{ #category : #printing }
SLVMConstantExpresionGetElementPointer >> pointer [
	^ parameters first
]

{ #category : #printing }
SLVMConstantExpresionGetElementPointer >> pointer: pointer indices: indices [
	| pointerType memberType |
	self parameters: { pointer } , indices.
	self assert: (pointer type isPointerType or: [pointer type isDynamicObjectType ]).
	pointerType := pointer type.
	memberType := pointerType.
	inBounds := true.
	indices do: [ :index |
		inBounds := inBounds and: [ memberType isMemberInBoundsAt: index ].
		memberType := memberType typeOfMemberAt: index
	].

	type := SLVMPointerType size: pointerType size baseType: memberType storage: pointerType storage

]

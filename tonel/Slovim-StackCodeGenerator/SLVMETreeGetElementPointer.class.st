Class {
	#name : #SLVMETreeGetElementPointer,
	#superclass : #SLVMETreeExpression,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #accessing }
SLVMETreeGetElementPointer >> accept: aVisitor [
	^ aVisitor visitGetElementPointer: self
]

{ #category : #accessing }
SLVMETreeGetElementPointer >> indices [
	^ parameters allButFirst
]

{ #category : #accessing }
SLVMETreeGetElementPointer >> indicesWithStrides [
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
SLVMETreeGetElementPointer >> isGetElementPointer [
	^ true
]

{ #category : #accessing }
SLVMETreeGetElementPointer >> name [
	^ 'getElementPointer'
]

{ #category : #accessing }
SLVMETreeGetElementPointer >> pointer [
	^ parameters first
]

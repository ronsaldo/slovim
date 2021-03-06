Class {
	#name : #SLVMETreeGetElementPointer,
	#superclass : #SLVMETreeExpression,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #accessing }
SLVMETreeGetElementPointer >> accept: aVisitor [
	^ aVisitor visitGetElementPointer: self
]

{ #category : #testing }
SLVMETreeGetElementPointer >> canReferencesBeMerged: references [
	(super canReferencesBeMerged: references) ifTrue: [ ^ true ].	
	^ self hasConstantIndices
]

{ #category : #testing }
SLVMETreeGetElementPointer >> hasConstantIndices [
	self indices do: [ :index | index isConstantValue ifFalse: [^ false] ].
	^ true
]

{ #category : #accessing }
SLVMETreeGetElementPointer >> indexAt: anIndex [
	^ parameters at: anIndex + 1
]

{ #category : #accessing }
SLVMETreeGetElementPointer >> indexCount [
	^ parameters size - 1
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

{ #category : #testing }
SLVMETreeGetElementPointer >> isPureExpression [
	self parameters do: [ :param | param isPureExpression ifFalse: [ ^ false ] ].
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

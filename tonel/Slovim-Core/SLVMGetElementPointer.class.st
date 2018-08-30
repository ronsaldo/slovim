Class {
	#name : #SLVMGetElementPointer,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'inBounds'
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
SLVMGetElementPointer >> aggregateInBoundIndices [
	| result index |
	self assert: inBounds.
	result := Array new: parameters size - 2.
	1 to: result size do: [ :i |
		index := parameters at: i + 2.
		self assert: index isConstantValue.
		result at: i put: index value
	].
	^ result
]

{ #category : #accessing }
SLVMGetElementPointer >> firstIndex [
	^ parameters second
]

{ #category : #testing }
SLVMGetElementPointer >> hasConstantInBoundsIndices [
	^ inBounds and: [ self hasConstantIndices ]
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

{ #category : #testing }
SLVMGetElementPointer >> isInBounds [
	^ inBounds
]

{ #category : #testing }
SLVMGetElementPointer >> isPureInstruction [
	^ true
]

{ #category : #accessing }
SLVMGetElementPointer >> lastIndex [
	^ parameters last
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
	inBounds := true.
	indices do: [ :index |
		inBounds := inBounds and: [ memberType isMemberInBoundsAt: index ].
		memberType := memberType typeOfMemberAt: index
	].

	type := SLVMPointerType size: pointerType size baseType: memberType storage: pointerType storage

]

{ #category : #accessing }
SLVMGetElementPointer >> signature [
	^ super signature , {inBounds}
]

{ #category : #accessing }
SLVMGetElementPointer >> type [
	^ type
]

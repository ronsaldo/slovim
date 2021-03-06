Class {
	#name : #SLVMPrimitiveType,
	#superclass : #SLVMType,
	#instVars : [
		'sname',
		'name',
		'size',
		'alignment'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #'instance creation' }
SLVMPrimitiveType class >> name: aName size: aSize alignment: anAlignment [
	^ self new name: aName; size: aSize; alignment: anAlignment; yourself
]

{ #category : #comparing }
SLVMPrimitiveType >> = other [
	^ self class == other class and: [ size = other size and: [ alignment = other alignment ] ]
]

{ #category : #accessing }
SLVMPrimitiveType >> alignment [
	^ alignment
]

{ #category : #accessing }
SLVMPrimitiveType >> alignment: anObject [
	alignment := anObject
]

{ #category : #comparing }
SLVMPrimitiveType >> internalHash [
	^ (self class hash bitXor: size hash) bitXor: alignment hash
]

{ #category : #testing }
SLVMPrimitiveType >> isPrimitiveType [
	^ true
]

{ #category : #testing }
SLVMPrimitiveType >> isScalarType [
	^ true
]

{ #category : #printing }
SLVMPrimitiveType >> mnemonic [
	^ self asFullSExpression
]

{ #category : #accessing }
SLVMPrimitiveType >> name [
	^ name
]

{ #category : #accessing }
SLVMPrimitiveType >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMPrimitiveType >> printOn: aStream [
	aStream nextPutAll: name
]

{ #category : #'pointer accessing' }
SLVMPrimitiveType >> readFromPointer: pointer [
	^ pointer perform: self selectorForLoadingFromPointer
]

{ #category : #'as yet unclassified' }
SLVMPrimitiveType >> selectorForStoring [
	^ (self selectorForLoadingFromPointer , ':') asSymbol
]

{ #category : #'as yet unclassified' }
SLVMPrimitiveType >> selectorForStoringIntoPointer [
	^ (self selectorForLoadingFromPointer , 'Into:') asSymbol
]

{ #category : #accessing }
SLVMPrimitiveType >> size [
	^ size
]

{ #category : #accessing }
SLVMPrimitiveType >> size: anObject [
	size := anObject
]

{ #category : #'as yet unclassified' }
SLVMPrimitiveType >> withRankOf: otherType [
	otherType isVectorType ifTrue: [
		^ SLVMVectorType baseType: self elements: otherType elements
	].
	otherType isMatrixType ifTrue: [ 
		^ SLVMMatrixType baseType: self rows: otherType rows columns: otherType columns
	].

	^ self
]

{ #category : #writing }
SLVMPrimitiveType >> write: value intoPointer: pointer [
	^ value perform: self selectorForStoringIntoPointer with: pointer
]

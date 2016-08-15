Class {
	#name : #SLVMStructureType,
	#superclass : #SLVMType,
	#instVars : [
		'types',
		'kind',
		'name',
		'names',
		'alignment',
		'size',
		'offsets'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #'as yet unclassified' }
SLVMStructureType class >> blockKind [
	^ #block
]

{ #category : #'as yet unclassified' }
SLVMStructureType class >> bufferBlockKind [
	^ #bufferBlock
]

{ #category : #'as yet unclassified' }
SLVMStructureType class >> genericKind [
	^ #generic
]

{ #category : #construction }
SLVMStructureType class >> name: structureName types: typeList kind: structureKind names: fieldNames [
	^ self new name: structureName; types: typeList; kind: structureKind; names: fieldNames; yourself
]

{ #category : #comparing }
SLVMStructureType >> = other [
	^ self class == other class and: [ kind = other kind and: [ types = other types ] ]
]

{ #category : #visitor }
SLVMStructureType >> accept: aVisitor [
	^ aVisitor visitStructureType: self
]

{ #category : #accessing }
SLVMStructureType >> alignment [
	^ alignment
]

{ #category : #private }
SLVMStructureType >> computeLayout [
	| currentOffset offset |
	currentOffset := 0.
	alignment := 1.
	offsets := types collect: [ :type |
		currentOffset := currentOffset alignedTo: type alignment.
		offset := currentOffset.
		currentOffset := currentOffset + type size.
		alignment := alignment max: type alignment.
		offset.
	].
	size := currentOffset alignedTo: alignment.
]

{ #category : #comparing }
SLVMStructureType >> hash [
	^ self class hash bitXor: (kind hash bitXor: types hash)
]

{ #category : #testing }
SLVMStructureType >> isScalarType [
	^ false
]

{ #category : #testing }
SLVMStructureType >> isStructureType [
	^ true
]

{ #category : #accessing }
SLVMStructureType >> kind [
	^ kind
]

{ #category : #accessing }
SLVMStructureType >> kind: anObject [
	kind := anObject
]

{ #category : #accessing }
SLVMStructureType >> memberAt: constantValue [
	self assert: constantValue isConstant.
	^ types at: constantValue value + 1
]

{ #category : #accessing }
SLVMStructureType >> name [
	^ name
]

{ #category : #accessing }
SLVMStructureType >> name: aName [
	name := aName
]

{ #category : #accessing }
SLVMStructureType >> names [
	^ names
]

{ #category : #accessing }
SLVMStructureType >> names: anObject [
	names := anObject
]

{ #category : #accessing }
SLVMStructureType >> offsets [
	^ offsets
]

{ #category : #printing }
SLVMStructureType >> printOn: aStream [
	aStream nextPutAll: 'struct {'.
	types doWithIndex: [ :type :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: type
	].
	aStream nextPutAll: '}'.
	
]

{ #category : #accessing }
SLVMStructureType >> size [
	^ size
]

{ #category : #accessing }
SLVMStructureType >> types [
	^ types
]

{ #category : #accessing }
SLVMStructureType >> types: anObject [
	types := anObject.
	self computeLayout.
]

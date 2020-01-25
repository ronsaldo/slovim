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
		'offsets',
		'behavior',
		'memberAnnotations'
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
SLVMStructureType class >> builtInBlockKind [
	^ #builtInBlock
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
	^ self == other
]

{ #category : #visitor }
SLVMStructureType >> accept: aVisitor [
	^ aVisitor visitStructureType: self
]

{ #category : #accessing }
SLVMStructureType >> alignment [
	^ alignment
]

{ #category : #accessing }
SLVMStructureType >> behavior [
	^ behavior
]

{ #category : #accessing }
SLVMStructureType >> behavior: anObject [
	behavior := anObject
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

{ #category : #'as yet unclassified' }
SLVMStructureType >> defaultConstant [
	^ SLVMConstant zeroInitializer: self
]

{ #category : #'as yet unclassified' }
SLVMStructureType >> defaultFullConstant [
	^ SLVMConstant structure: self slots: (types collect: [:each | each defaultFullConstant])
]

{ #category : #printing }
SLVMStructureType >> fullPrintOn: aStream [
	self fullPrintOn: aStream fromPrint: false
]

{ #category : #printing }
SLVMStructureType >> fullPrintOn: aStream fromPrint: aBoolean [
	types ifNil: [
		aStream nextPutAll: 'opaque struct'.
		name ifNotNil: [
			aStream nextPutAll: name.
		].
		^ self
	].

	aStream nextPutAll: 'struct {'.
	types doWithIndex: [ :type :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: type
	].
	aStream nextPutAll: '}'.
	aBoolean ifFalse: [ aStream cr ]
	
]

{ #category : #comparing }
SLVMStructureType >> hash [
	^ self identityHash
]

{ #category : #testing }
SLVMStructureType >> isAggregateType [
	^ true
]

{ #category : #accessing }
SLVMStructureType >> isMemberInBoundsAt: index [
	^ index isConstantValue and: [ index value < types size  ]
]

{ #category : #testing }
SLVMStructureType >> isPacked [
	^ false
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

{ #category : #'as yet unclassified' }
SLVMStructureType >> loadValueFromPointerWith: irBuilder [
	behavior ifNotNil: [ 
		^ irBuilder
			pushLiteralVariable: behavior binding;
			send: #_slvm_loadStructureValue:
	].

	self halt
	
]

{ #category : #accessing }
SLVMStructureType >> memberAnnotations [
	^ memberAnnotations
]

{ #category : #accessing }
SLVMStructureType >> memberAnnotations: anObject [
	memberAnnotations := anObject
]

{ #category : #accessing }
SLVMStructureType >> memberAt: constantValue [
	self assert: constantValue isConstant.
	^ types at: constantValue value + 1
]

{ #category : #private }
SLVMStructureType >> minimalAlignment: anAlignment [
	alignment := alignment max: anAlignment.
	size := size alignedTo: alignment.
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

{ #category : #'element accessing' }
SLVMStructureType >> offsetWithIndex: index [
	self assert: index isConstantValue.
	^ offsets at: index value + 1
]

{ #category : #accessing }
SLVMStructureType >> offsets [
	^ offsets
]

{ #category : #printing }
SLVMStructureType >> printOn: aStream [
	name ifNotNil: [
		aStream nextPutAll: name.
		^ self
	].
	self fullPrintOn: aStream fromPrint: true
]

{ #category : #'pointer accessing' }
SLVMStructureType >> readFromPointer: pointer [
	behavior ifNil: [ ^ super readFromPointer: pointer ].
	^ pointer _slvm_loadStructureValue: behavior
]

{ #category : #accessing }
SLVMStructureType >> shortName [
	^ 'struct ' , (name ifNil: [ '' ])
]

{ #category : #accessing }
SLVMStructureType >> size [
	^ size
]

{ #category : #'as yet unclassified' }
SLVMStructureType >> storeAndPopValueIntoPointerWith: irBuilder [
	behavior ifNotNil: [ 
		^ irBuilder
			pushLiteralVariable: behavior binding;
			send: #_slvm_storeStructureValueInto:behavior:;
			popTop
	].

	self halt
	
]

{ #category : #'as yet unclassified' }
SLVMStructureType >> storeAndPopValueWith: irBuilder [
	behavior ifNotNil: [ 
		^ irBuilder
			pushLiteralVariable: behavior binding;
			send: #_slvm_storeStructureValue:behavior:;
			popTop
	].

	self halt
	
]

{ #category : #'as yet unclassified' }
SLVMStructureType >> storeValueIntoPointerWith: irBuilder [
	behavior ifNotNil: [ 
		^ irBuilder
			pushLiteralVariable: behavior binding;
			send: #_slvm_storeStructureValueInto:behavior:
	].

	self halt
	
]

{ #category : #'as yet unclassified' }
SLVMStructureType >> storeValueWith: irBuilder [
	behavior ifNotNil: [ 
		^ irBuilder
			pushLiteralVariable: behavior binding;
			send: #_slvm_storeStructureValue:behavior:
	].

	self halt
	
]

{ #category : #'element accessing' }
SLVMStructureType >> strideWithIndex: index [
	self assert: index isConstantValue.
	^ 0
]

{ #category : #accessing }
SLVMStructureType >> typeOfMemberAt: index [
	^ self memberAt: index
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

{ #category : #'pointer accessing' }
SLVMStructureType >> write: value intoPointer: pointer [
	behavior ifNil: [ pointer _slvm_storeBytes: value count: self size ].
	^ pointer _slvm_storeStructureValue: value behavior: behavior
]

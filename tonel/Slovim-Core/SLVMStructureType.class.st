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
		'memberAnnotations',
		'fullSExpression'
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

{ #category : #printing }
SLVMStructureType class >> mnemonic [
	^ #struct
]

{ #category : #construction }
SLVMStructureType class >> name: structureName types: typeList kind: structureKind names: fieldNames [
	^ self new name: structureName; types: typeList; kind: structureKind; names: fieldNames; yourself
]

{ #category : #comparing }
SLVMStructureType >> = other [
	self class == other class ifFalse: [ ^ false ].
	
	(name isNotNil or: [other name isNotNil]) ifTrue: [ ^ self == other ].
	^ types = other types
]

{ #category : #visitor }
SLVMStructureType >> accept: aVisitor [
	^ aVisitor visitStructureType: self
]

{ #category : #accessing }
SLVMStructureType >> alignment [
	alignment ifNil: [ self computeLayout ].
	^ alignment
]

{ #category : #converting }
SLVMStructureType >> asFullSExpression [
	^ fullSExpression ifNil: [
		fullSExpression := {self mnemonic . name . kind . types collect: [:each | each asSExpression]. names . #() }
	]
]

{ #category : #converting }
SLVMStructureType >> asSExpression [
	name ifNotNil: [ ^ { self mnemonic . name } ].
	^ super asSExpression
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

{ #category : #converting }
SLVMStructureType >> decodeFromFullSExpression: encodedType context: decodingContext [
	self assert: encodedType size = 6.
	kind := encodedType third.
	names := encodedType fifth.
	types := encodedType fourth collect: [:each | decodingContext decodeSExpressionType: each].
]

{ #category : #'as yet unclassified' }
SLVMStructureType >> defaultConstant [
	^ SLVMConstant zeroInitializer: self
]

{ #category : #'as yet unclassified' }
SLVMStructureType >> defaultFullConstant [
	^ SLVMConstant structure: self slots: (types collect: [:each | each defaultFullConstant])
]

{ #category : #'instance creation' }
SLVMStructureType >> fromOopUsingLowcodeWith: builder [
	^ builder lowcodeFirstFieldPointer
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
	name ifNotNil: [ ^ types hash ].
	^ self identityHash
]

{ #category : #'as yet unclassified' }
SLVMStructureType >> importIntoModule: targetModule fromModule: sourceModule [
	name ifNotNil: [
		(targetModule addStructure: self) ifFalse: [ ^ self ]
	].

	types do: [ :each | each importIntoModule: targetModule fromModule: sourceModule ]
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

{ #category : #'as yet unclassified' }
SLVMStructureType >> pushConstant: constant usingLowcodeWith: builder [
	builder
		pushLiteral: constant;
		lowcodeFirstFieldPointer
]

{ #category : #'as yet unclassified' }
SLVMStructureType >> pushFromMemoryUsingLowcodeWith: builder [
	self error: 'I should not be called'
]

{ #category : #'as yet unclassified' }
SLVMStructureType >> pushLocal: location usingLowcodeWith: aCodeGenerator [
	^ aCodeGenerator lowcodeLoadLocalAddress: location
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
	size ifNil: [ self computeLayout ].
	^ size
]

{ #category : #'as yet unclassified' }
SLVMStructureType >> storeAndPopStackTopIntoMemoryUsingLowcodeWith: builder [
	builder lowcodeMemcpyFixed: size
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

{ #category : #'instance creation' }
SLVMStructureType >> toOopUsingLowcodeWith: builder [
	| pointerLocation |
	self assert: behavior isNotNil.
	pointerLocation := builder allocateTemporaryPointer.
	builder
		lowcodeStoreLocalPointer: pointerLocation;
		pushLiteralVariable: behavior binding;
		send: #basicNew;
		pushDup;
		lowcodeFirstFieldPointer;
		lowcodeLoadLocalPointer: pointerLocation;
		lowcodeMemcpyFixed: self size
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

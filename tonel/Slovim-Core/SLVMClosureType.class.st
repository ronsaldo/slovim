Class {
	#name : #SLVMClosureType,
	#superclass : #SLVMType,
	#instVars : [
		'functionType',
		'captures',
		'kind',
		'normalFunctionTypeInfo',
		'fullSExpression',
		'addressSpace',
		'hasStructReturnPointer'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #'as yet unclassified' }
SLVMClosureType class >> functionType: aFunctionType hasStructReturnPointer: hasStructReturnPointer kind: kind captures: captures addressSpace: addressSpace [
	^ self new functionType: aFunctionType; hasStructReturnPointer: hasStructReturnPointer; kind: kind; captures: captures; addressSpace: addressSpace
]

{ #category : #printing }
SLVMClosureType class >> mnemonic [
	^ #closure
]

{ #category : #comparing }
SLVMClosureType >> = other [
	^ self class = other class and: [ functionType = other functionType and: [ captures = other captures ] ]
]

{ #category : #comparing }
SLVMClosureType >> accept: aVisitor [
	^ aVisitor visitClosureType: self
]

{ #category : #accessing }
SLVMClosureType >> addressSpace [
	^ addressSpace
]

{ #category : #accessing }
SLVMClosureType >> addressSpace: anObject [
	addressSpace := anObject
]

{ #category : #converting }
SLVMClosureType >> asFullSExpression [
	^ fullSExpression ifNil: [ fullSExpression := {
		self mnemonic . kind .
		functionType asSExpression  .
		captures collect: [:each | each asSExpression] as: Array
		}
	]
]

{ #category : #'as yet unclassified' }
SLVMClosureType >> capturedEnvironmentStructureTypeWith: compilationTarget [
	^ SLVMStructureType name: nil types: self sortedCapturedTypes kind: SLVMStructureType genericKind names: ((1 to: captures size) collect: [:i | 'c' , i asString])
]

{ #category : #accessing }
SLVMClosureType >> captures [
	^ captures
]

{ #category : #accessing }
SLVMClosureType >> captures: anObject [
	captures := anObject
]

{ #category : #accessing }
SLVMClosureType >> functionType [
	^ functionType
]

{ #category : #accessing }
SLVMClosureType >> functionType: anObject [
	functionType := anObject
]

{ #category : #accessing }
SLVMClosureType >> hasStructReturnPointer [
	^ hasStructReturnPointer
]

{ #category : #accessing }
SLVMClosureType >> hasStructReturnPointer: anObject [
	hasStructReturnPointer := anObject
]

{ #category : #comparing }
SLVMClosureType >> internalHash [	
	^ (self class hash bitXor: functionType hash) bitXor: captures hash

]

{ #category : #testing }
SLVMClosureType >> isClosureType [
	^ true
]

{ #category : #accessing }
SLVMClosureType >> kind [
	^ kind
]

{ #category : #accessing }
SLVMClosureType >> kind: anObject [
	kind := anObject
]

{ #category : #comparing }
SLVMClosureType >> name [
	^ self printString
]

{ #category : #'as yet unclassified' }
SLVMClosureType >> normalFunctionTypeWith: compilationTarget [
	| capturedEnvironmentStructure closureStructureType closurePointer closureFunctionType genericClosurePointer genericClosureFunctionType genericClosureFunctionPointer |
	normalFunctionTypeInfo ifNotNil: [ ^ normalFunctionTypeInfo ].
	
	capturedEnvironmentStructure := self capturedEnvironmentStructureTypeWith: compilationTarget.
	
	closureStructureType := SLVMStructureType new kind: SLVMStructureType genericKind.
	closurePointer := compilationTarget pointerTo: closureStructureType storage: addressSpace.

	hasStructReturnPointer ifTrue: [ 
		closureFunctionType := SLVMFunctionType callingConvention: functionType callingConvention
			arguments: {functionType arguments first . closurePointer} , functionType arguments allButFirst returnType: functionType returnType.
	] ifFalse: [ 
		closureFunctionType := SLVMFunctionType callingConvention: functionType callingConvention
			arguments: {closurePointer} , functionType arguments returnType: functionType returnType.
	].

	
	genericClosurePointer := compilationTarget objectModel genericClosurePointerForKind: kind.
	genericClosureFunctionType := SLVMFunctionType callingConvention: functionType callingConvention
		arguments: {genericClosurePointer} , functionType arguments returnType: functionType returnType.
	genericClosureFunctionPointer := SLVMPointerType size: compilationTarget pointerSize baseType: genericClosureFunctionType storage: SLVMType genericStorage.
	
	compilationTarget objectModel fillClosureStructure: closureStructureType functionPointerType: genericClosureFunctionPointer capturedEnvironmentStructure: capturedEnvironmentStructure kind: kind.
	
	normalFunctionTypeInfo := { closureFunctionType . capturedEnvironmentStructure . closureStructureType }.
	^ normalFunctionTypeInfo
]

{ #category : #comparing }
SLVMClosureType >> printOn: aStream [
	aStream nextPutAll: 'closure('; print: kind; nextPutAll: ') '; print: functionType; nextPut: $[.
	captures doWithIndex: [ :cap :index |
		index > 1 ifTrue: [ aStream space ].
		aStream print: cap
	].
	aStream nextPut: $]
]

{ #category : #'as yet unclassified' }
SLVMClosureType >> sortedCapturedTypes [
	| dynamicCaptures normalCaptures |
	dynamicCaptures := OrderedCollection new.
	normalCaptures := OrderedCollection new.
	captures do: [ :cap |
		cap isDynamicObjectPointerType ifTrue: [
			dynamicCaptures add: cap
		] ifFalse: [
			normalCaptures add: cap
		]
	].
	^ dynamicCaptures asArray, normalCaptures asArray
]

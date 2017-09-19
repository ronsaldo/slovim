Class {
	#name : #SLVMClosureType,
	#superclass : #SLVMType,
	#instVars : [
		'functionType',
		'captures',
		'normalFunctionTypeInfo'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #'as yet unclassified' }
SLVMClosureType class >> functionType: aFunctionType captures: captures [
	^ self new functionType: aFunctionType; captures: captures
]

{ #category : #comparing }
SLVMClosureType >> = other [
	^ self class = other class and: [ functionType = other functionType and: [ captures = other captures ] ]
]

{ #category : #comparing }
SLVMClosureType >> accept: aVisitor [
	^ aVisitor visitClosureType: self
]

{ #category : #'as yet unclassified' }
SLVMClosureType >> capturedEnvironmentStructureTypeWith: compilationTarget [
	^ SLVMStructureType name: #closureEnvironment types: self sortedCapturedTypes kind: SLVMStructureType genericKind names: ((1 to: captures size) collect: [:i | 'c' , i asString])
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

{ #category : #comparing }
SLVMClosureType >> internalHash [	
	^ (self class hash bitXor: functionType hash) bitXor: captures hash

]

{ #category : #testing }
SLVMClosureType >> isClosureType [
	^ true
]

{ #category : #comparing }
SLVMClosureType >> name [
	^ self printString
]

{ #category : #'as yet unclassified' }
SLVMClosureType >> normalFunctionTypeWith: compilationTarget [
	| capturedEnvironmentStructure closureStructureType closurePointer closureFunctionType closureFunctionPointer |
	normalFunctionTypeInfo ifNotNil: [ ^ normalFunctionTypeInfo ].
	
	capturedEnvironmentStructure := self capturedEnvironmentStructureTypeWith: compilationTarget.
	
	closureStructureType := SLVMStructureType new name: #closure; kind: SLVMStructureType genericKind.
	closurePointer := SLVMPointerType size: compilationTarget pointerSize baseType: closureStructureType storage: SLVMType genericStorage.
	
	closureFunctionType := SLVMFunctionType callingConvention: functionType callingConvention
		arguments: {closurePointer} , functionType arguments returnType: functionType returnType.
	closureFunctionPointer := SLVMPointerType size: compilationTarget pointerSize baseType: closureFunctionType storage: SLVMType genericStorage.
	
	compilationTarget objectModel fillClosureStructure: closureStructureType functionPointerType: closureFunctionPointer capturedEnvironmentStructure: capturedEnvironmentStructure.
	
	normalFunctionTypeInfo := { closureFunctionType . capturedEnvironmentStructure . closureStructureType }.
	^ normalFunctionTypeInfo
]

{ #category : #comparing }
SLVMClosureType >> printOn: aStream [
	aStream nextPutAll: 'closure '; print: functionType; nextPut: $[.
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
		cap isDynamicObjectType ifTrue: [
			dynamicCaptures add: cap
		] ifFalse: [
			normalCaptures add: cap
		]
	].
	^ dynamicCaptures asArray, normalCaptures asArray
]

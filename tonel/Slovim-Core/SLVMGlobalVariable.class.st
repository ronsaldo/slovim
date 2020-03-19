"
I representa global variable.
"
Class {
	#name : #SLVMGlobalVariable,
	#superclass : #SLVMGlobalValue,
	#instVars : [
		'valueType',
		'type',
		'initialValue',
		'readOnly',
		'headerValue',
		'minimalAlignment',
		'threadLocalModel'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMGlobalVariable class >> mnemonic [
	^ #variable
]

{ #category : #construction }
SLVMGlobalVariable class >> module: module name: varName valueType: valueType storage: storage [
	| var |
	var := self pointerSize: module compilationTarget pointerSize name: varName valueType: valueType  storage: storage.
	module add: var.
	^ var
]

{ #category : #construction }
SLVMGlobalVariable class >> pointerSize: pointerSize name: aString valueType: aFunctionType storage: storageClass [
	^ self new name: aString; pointerSize: pointerSize valueType: aFunctionType storage: storageClass; yourself
]

{ #category : #visitor }
SLVMGlobalVariable >> accept: aVisitor [
	^ aVisitor visitGlobalVariable: self
]

{ #category : #printing }
SLVMGlobalVariable >> asFullSExpression [
	^ { self mnemonic . type storage .  self globalValueIndex . name . valueType asSExpression .
		self globalValueAttributesAsSExpression.
		#readOnly . readOnly.
		#value . initialValue ifNotNil: [ initialValue asSExpression ].
	}
]

{ #category : #'as yet unclassified' }
SLVMGlobalVariable >> createPublicInterfaceDeclarationVersionIn: targetModule [
	| resultVar |
	self isPubliclyExported ifFalse: [ ^ self ].
	resultVar := self class module: targetModule name: name valueType: valueType storage: type storage.
	resultVar makeExternal.
	module symbolMapToHighLevel at: name ifPresent: [ :highLevelEntity |
		targetModule addHighLevelEntity: highLevelEntity mapToGlobalValue: resultVar 
	].

	^ resultVar
]

{ #category : #accessing }
SLVMGlobalVariable >> customSection [
	^ self propertyAt: #customSection ifAbsent: [ nil ]
]

{ #category : #accessing }
SLVMGlobalVariable >> customSection: aSectionName [
	self propertyAt: #customSection put: aSectionName
]

{ #category : #'as yet unclassified' }
SLVMGlobalVariable >> decodeDeclarationFromSExpression: encodedGlobal context: context [
	name := encodedGlobal fourth.
	self pointerSize: context compilationTarget pointerSize
		valueType: (context decodeSExpressionType: encodedGlobal fifth)
		storage: encodedGlobal second.
	self decodeGlobalValueAttributesFromSExpression: encodedGlobal sixth context: context.

]

{ #category : #'as yet unclassified' }
SLVMGlobalVariable >> decodeDefinitionFromSExpression: encodedGlobal context: context [
	| dict |
	dict := Dictionary newFromPairs: (encodedGlobal allButFirst: 6).
	readOnly := dict at: #readOnly ifAbsent: [ false ].
	(dict at: #value ifAbsent: [ nil ]) ifNotNil: [ :encodedInitialValue |
		initialValue := context decodeSExpressionValue: encodedInitialValue
	].
]

{ #category : #printing }
SLVMGlobalVariable >> fullPrintOn: aStream [
	aStream nextPutAll: 'global @'; print: type; space; nextPutAll: (name ifNil: [#anonymous]); space.
	self printPropertiesOn: aStream.
	aStream cr
]

{ #category : #'as yet unclassified' }
SLVMGlobalVariable >> headerReferenceOfType: aType [
	self assert: (aType isPointerType or: [ aType isDynamicObjectPointerType ]).
	^ SLVMConstantGlobalVariableHeaderReference new
		type: aType;
		globalVariable: self
]

{ #category : #accessing }
SLVMGlobalVariable >> headerValue [
	^ headerValue
]

{ #category : #accessing }
SLVMGlobalVariable >> headerValue: anObject [
	headerValue := anObject
]

{ #category : #'as yet unclassified' }
SLVMGlobalVariable >> importIntoModule: targetModule fromModule: sourceModule [
	| result |
	result := super importIntoModule: targetModule fromModule: sourceModule.
	targetModule importType: valueType fromModule: module. 
	^ result
]

{ #category : #accessing }
SLVMGlobalVariable >> initialValue [
	^ initialValue
]

{ #category : #accessing }
SLVMGlobalVariable >> initialValue: anObject [
	initialValue := anObject
]

{ #category : #initialization }
SLVMGlobalVariable >> initialize [
	super initialize.
	readOnly := false.
]

{ #category : #testing }
SLVMGlobalVariable >> isGlobalVariable [
	^ true
]

{ #category : #accessing }
SLVMGlobalVariable >> minimalAlignment [
	^ minimalAlignment
]

{ #category : #accessing }
SLVMGlobalVariable >> minimalAlignment: anObject [
	minimalAlignment := anObject
]

{ #category : #accessing }
SLVMGlobalVariable >> pointerSize: pointerSize valueType: aType storage: storageClass [
	self assert: aType isSlovimType.
	valueType := aType.
	type := SLVMPointerType size: pointerSize baseType: valueType storage: storageClass.
]

{ #category : #accessing }
SLVMGlobalVariable >> readOnly [
	^ readOnly
]

{ #category : #accessing }
SLVMGlobalVariable >> readOnly: anObject [
	readOnly := anObject
]

{ #category : #asserting }
SLVMGlobalVariable >> shouldBePromotedToConstant [
	^ self propertyAt: #shouldBePromotedToConstant ifAbsent: [ false ]
]

{ #category : #asserting }
SLVMGlobalVariable >> shouldBePromotedToConstant: aBoolean [
	self propertyAt: #shouldBePromotedToConstant put: aBoolean
]

{ #category : #accessing }
SLVMGlobalVariable >> threadLocalModel [
	^ threadLocalModel
]

{ #category : #accessing }
SLVMGlobalVariable >> threadLocalModel: anObject [
	threadLocalModel := anObject
]

{ #category : #accessing }
SLVMGlobalVariable >> type [
	^ type
]

{ #category : #accessing }
SLVMGlobalVariable >> valueType [
	^ valueType
]

{ #category : #'as yet unclassified' }
SLVMGlobalVariable >> withGeneralDynamicTLSModel [
	threadLocalModel := #generalDynamicTLSModel
]

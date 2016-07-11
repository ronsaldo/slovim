"
I provide common processes for translating a Slovim module into a high-level language such as C, GLSL, HLSL or Javascript.
"
Class {
	#name : #SLVMHighLevelLanguageCodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'typeDeclarations',
		'globalVariableDeclarations',
		'functionDefinitions',
		'translatedValueDictionary',
		'outputStream',
		'indentationLevel',
		'gensymCount'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> decreaseIndentationLevel [
	indentationLevel := indentationLevel - 1.
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> emitLine: aString [
	self
		emitTabs;
		emitString: aString;
		emitNewline
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> emitNewline [
	outputStream lf
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> emitPrelude [

]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> emitString: aString [
	outputStream nextPutAll: aString
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> emitTabs [
	1 to: indentationLevel do: [ :i | outputStream tab ]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> emitTranslatedCode: nodes [
	^ ByteString streamContents: [ :out |
		outputStream := out.
		self emitPrelude.
		nodes do: [ :node |
			node translateWith: self
		]
	]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> functionTranslation: value do: aBlock [
	| hlNode |
	^ translatedValueDictionary at: value ifAbsentPut: [
		hlNode := aBlock value.
		functionDefinitions add: hlNode.
		hlNode
	]
]

{ #category : #'as yet unclassified' }
SLVMHighLevelLanguageCodeGenerator >> generateSymbol [
	gensymCount := gensymCount + 1.
	^ ('_g', gensymCount asString) asSymbol
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> globalValueTranslation: value do: aBlock [
	| hlNode |
	^ translatedValueDictionary at: value ifAbsentPut: [
		hlNode := aBlock value.
		globalVariableDeclarations add: hlNode.
		hlNode
	]
]

{ #category : #testing }
SLVMHighLevelLanguageCodeGenerator >> hasFunctionOverloadingSupport [
	^ true
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> increaseIndentationLevel [
	indentationLevel := indentationLevel + 1.
]

{ #category : #initialization }
SLVMHighLevelLanguageCodeGenerator >> initialize [
	super initialize.
	indentationLevel := 0.
	gensymCount := 0.
]

{ #category : #testing }
SLVMHighLevelLanguageCodeGenerator >> isAbstract [
	^ self == SLVMHighLevelLanguageCodeGenerator
]

{ #category : #testing }
SLVMHighLevelLanguageCodeGenerator >> isAddingStructureKindName [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMHighLevelLanguageCodeGenerator >> isBlackListedSymbol: aSymbol [
	^ false
]

{ #category : #'as yet unclassified' }
SLVMHighLevelLanguageCodeGenerator >> isValidSymbol: aSymbol [
	(aSymbol isNil or: [aSymbol isEmpty]) ifTrue: [ ^ false ].
	aSymbol do: [ :char | (self isValidSymbolCharacter: char) ifFalse: [ ^ false ]].
	^ true
]

{ #category : #'as yet unclassified' }
SLVMHighLevelLanguageCodeGenerator >> isValidSymbolCharacter: char [
	^ (char >= $a and: [ char <= $z ]) or: [
		(char >= $A and: [ char <= $Z ]) or: [
		(char >= $0 and: [ char <= $9 ]) or: [
		char = $_]]]
		
]

{ #category : #'as yet unclassified' }
SLVMHighLevelLanguageCodeGenerator >> makeFunctionPrototypeString: function [
	| functionType |
	^ ByteString streamContents: [:out |
		functionType := function type.
		out
			nextPutAll: functionType returnType name; space;
			nextPutAll: function name; space; nextPut: $(.
			
		out nextPut: $)
	]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateArrayType: type [
	| baseType |
	baseType := self translateType: type baseType.
	^ SLVMHLArrayTypeNode new baseType: baseType; elements: type elements; name: baseType name; yourself
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateBasicType: aType [
	^ SLVMHLBasicTypeNode new name: (self translateBasicTypeName: aType); type: aType
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateBasicTypeName: aType [
	^ aType name
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateFunctionType: functionType [
	| returnType arguments |
	returnType := self translateType: functionType returnType.
	arguments := functionType arguments collect: [ :arg | self translateType: arg ].
	^ SLVMHLFunctionTypeNode new returnType: returnType; arguments: arguments; yourself
]

{ #category : #'as yet unclassified' }
SLVMHighLevelLanguageCodeGenerator >> translateHLFunction: function [
	self
		emitLine: (self makeFunctionPrototypeString: function);
		emitLine: '{';
		emitLine: '}';
		emitNewline
		
]

{ #category : #'as yet unclassified' }
SLVMHighLevelLanguageCodeGenerator >> translateHLStructure: structure [
	self
		emitLine: ('struct {1}' format: { structure name });
		emitLine: '{';
		withExtraIndentationLevel: [
			structure fields do: [ :field | self translateHLVariableDecl: field ]
		];
		emitLine: '};';
		emitNewline.
]

{ #category : #'as yet unclassified' }
SLVMHighLevelLanguageCodeGenerator >> translateHLVariableDecl: variableDecl [
	| variableType arrayBounds variableTypeString |
	variableType := variableDecl type.
	arrayBounds := variableType arrayBounds.
	variableTypeString := variableType name.

	self emitLine: ('{1} {2}{3};' format: { variableTypeString . variableDecl name . arrayBounds})

]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateModule: ssaModule [
	typeDeclarations := OrderedCollection new.
	globalVariableDeclarations := OrderedCollection new.
	functionDefinitions := OrderedCollection new.
	translatedValueDictionary := IdentityDictionary new.
	
	ssaModule globalValues do: [ :global |
		global accept: self
	].

	^ self emitTranslatedCode: typeDeclarations , globalVariableDeclarations , functionDefinitions
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateReferenceType: type [
	| baseType name |
	baseType := self translateType: type baseType.
	name := baseType name , '&'.
	^ SLVMHLReferenceTypeNode new baseType: baseType; name: name asSymbol; yourself
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateStructureType: type [
	| structure fieldName name |
	^ self typeTranslation: type do: [
		name := type name.
		self isAddingStructureKindName ifTrue: [
			(name isNotNil and: [type kind ~~ SLVMStructureType genericKind ]) ifTrue: [
				name := (name , '_' , type kind)  asString
			].
		].
	
		structure := SLVMHLStructureTypeNode new name: (self translateSymbol: name).
		structure
			kind: type kind; 
			fields: (type types collectWithIndex: [ :fieldType :fieldIndex |
			fieldName := nil.
			type names ifNotNil: [ fieldName := type names at: fieldIndex ].
			SLVMHLStructureTypeFieldNode new
				name: (self translateSymbol: fieldName);
				type: (self translateType: fieldType);
				yourself.
		]).
		structure
	]

]

{ #category : #'as yet unclassified' }
SLVMHighLevelLanguageCodeGenerator >> translateSymbol: aSymbol [
	(self isBlackListedSymbol: aSymbol) ifTrue: [ ^ self generateSymbol ].
	^ (self isValidSymbol: aSymbol) ifTrue: [ aSymbol ] ifFalse: [ self generateSymbol ]
	
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateType: aType [
	aType isStructureType ifTrue: [ ^ self translateStructureType: aType ].
	aType isArrayType ifTrue: [ ^ self translateArrayType: aType ].
	aType isFunctionType ifTrue: [ ^ self translateFunctionType: aType ].
	aType isReferenceType ifTrue: [ ^ self translateReferenceType: aType ]. 
	^ self translateBasicType: aType
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> typeTranslation: value do: aBlock [
	| hlNode |
	^ translatedValueDictionary at: value ifAbsentPut: [
		hlNode := aBlock value.
		typeDeclarations add: hlNode.
		hlNode
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitFunction: function [
	| functionType name |
	^ self functionTranslation: function do: [
		functionType := self translateType: function functionType.
		name := nil.
		self hasFunctionOverloadingSupport ifTrue: [ name := function unmangledName ].
		name ifNil: [ name := function name ].
		SLVMHLFunctionNode new name: (self translateSymbol: name); type: functionType; yourself
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitGlobalVariable: globalVariable [
	| valueType |
	^ self globalValueTranslation: globalVariable do: [
		valueType := self translateType: globalVariable valueType.
		SLVMHLVariableDeclNode new
			name: (self translateSymbol: globalVariable name);
			type: valueType;
			storage: globalVariable type storage;
			definition: globalVariable;
			yourself
	]
	
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> withExtraIndentationLevel: aBlock [
	self increaseIndentationLevel.
	aBlock ensure: [ self decreaseIndentationLevel ]
]

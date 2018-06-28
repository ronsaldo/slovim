Class {
	#name : #SLVMLLVMCodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'target',
		'llvmModule',
		'llvmContext',
		'translatedModuleElements',
		'translatedTypes',
		'usedNames',
		'translatedConstants',
		'debugCompileUnit',
		'unknownDebugFile',
		'convertedDebugFiles',
		'convertedDebugSourceLocations',
		'debugTranslator',
		'translatedDebugTypes',
		'translatedDebugElements',
		'convertedDebugVariables',
		'emptyDebugExpression'
	],
	#pools : [
		'SAsmDWConstants'
	],
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> buildFunction: slvmFunction debugInformationInto: llvmfunction [
	| subprogram debugFile |
	(self isEmittingDebugInformation not or: [slvmFunction hasProperty: #omitDebugInformation]) ifTrue: [ ^ nil ].
	slvmFunction isEmpty ifTrue: [ ^ nil ].
	
	subprogram := (LLVMDISubprogram for: llvmModule)
		distinct;
		scope: debugCompileUnit;
		unit: debugCompileUnit;
		isLocal: (slvmFunction isPublic or: [ slvmFunction isExternal ]) not;
		isDefinition: true;
		type: (self translateDebugType: slvmFunction functionType);
		variables: (LLVMMDDynamicTuple for: llvmModule)
		yourself.
	
	slvmFunction debugSourceLocation ifNotNil: [ :sourceLocation |
		debugFile := self convertDebugFile: sourceLocation sourceFile.
		subprogram
			file: debugFile;
			line: sourceLocation startLine;
			scopeLine: sourceLocation startLine.
			
		subprogram scope == debugCompileUnit ifTrue: [ 
			subprogram scope: debugFile
		].
	].
	
	slvmFunction name ifNotNil: [ 
		(slvmFunction unmangledName isNotNil and: [slvmFunction unmangledName ~= slvmFunction name]) ifTrue: [
			subprogram
				"linkageName: slvmFunction name;"
				name: (slvmFunction unmangledName)
		] ifFalse: [
			subprogram name: (slvmFunction name)
		].
	] ifNil: [ 
		slvmFunction unmangledName ifNotNil: [
			subprogram name: (slvmFunction unmangledName)
		] ifNil: [
			self flag: 'This could be a closure'.
			subprogram name: (self generateDebugAnonymousName).
		]
	].

	llvmfunction addDebugMetadata: subprogram.
	
	"slvmFunction arguments doWithIndex: [ :arg :index |
		arg debugInformation ifNotNil: [
			self createArgument: arg index: index debugInformationInto: subprogram.
		].
	]."

	^ subprogram
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> context [
	^ llvmContext ifNil: [ llvmContext := LLVMContext new ]
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> convertDebugFile: debugFile [
	^ self convertedDebugFiles at: debugFile ifAbsentPut: [
		(LLVMDIFile for: self llvmModule)
			filename: debugFile name;
			directory: debugFile directory;
			yourself
	]
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> convertDebugScope: scope fallbackTo: fallbackScope [
	scope ifNil: [ ^ fallbackScope ].
	self halt
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> convertDebugScope: debugScope withFile: debugFile [
	debugScope file == debugFile ifTrue: [ ^ debugScope ].
	^ self convertedDebugFiles at: {debugScope . debugFile} ifAbsentPut: [
		(LLVMDILexicalBlockFile for: self llvmModule)
			scope: debugScope;
			file: debugFile;
			yourself
	]
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> convertDebugSourceLocation: debugSourceLocation withScope: debugScope [
	| debugFile usedScope |
	debugFile := self convertDebugFile: debugSourceLocation sourceFile.
	usedScope := self convertDebugScope: debugScope withFile: debugFile.
	
	^ self convertedDebugSourceLocations at: { debugSourceLocation startLine . debugSourceLocation startColumn . usedScope } ifAbsentPut: [
		(LLVMDILocation for: self llvmModule)
			line: debugSourceLocation startLine;
			column: debugSourceLocation startColumn;
			scope: usedScope;
			yourself
	]
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> convertDebugVariable: debugVariable fallbackScopeInto: fallbackScope [
	| scope |
	^ self convertedDebugVariables at: { debugVariable . fallbackScope } ifAbsentPut: [ 
		scope := self convertDebugScope: debugVariable scope fallbackTo: fallbackScope.
	
		(LLVMDILocalVariable for: llvmModule)
			name: debugVariable name;
			arg: debugVariable argumentIndex;
			scope: scope;
			type: (self translateDebugType: debugVariable type);
			yourself.
	]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> convertLinkage: element [
	element isLinkOnceODR ifTrue: [ 
		^ LLVMGlobalValue linkOnceODRLinkage
	].
	element isPrivate ifTrue: [ 
		^ LLVMGlobalValue privateLinkage
	].

	self flag: 'TODO: Implement myself'.
	^ LLVMGlobalValue externalLinkage
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> convertName: aName [
	^ aName ifNotNil: [
		aName isLLVMAnon ifTrue: [ nil
		] ifFalse: [
			(usedNames includes: aName) ifTrue: [ nil
			] ifFalse: [
				usedNames add: aName.
				aName
			]
		]
	]
]

{ #category : #'as yet unclassified' }
SLVMLLVMCodeGenerator >> convertStructureContent: slvmStructure into: llvmStructure [
	llvmStructure elements: (slvmStructure types collect: [:type | self translateType: type])
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> convertedDebugFiles [
	^ convertedDebugFiles ifNil: [ convertedDebugFiles := Dictionary new ]
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> convertedDebugSourceLocations [
	^ convertedDebugSourceLocations ifNil: [ convertedDebugSourceLocations := Dictionary new ]
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> convertedDebugVariables [
	^ convertedDebugVariables ifNil: [ convertedDebugVariables := Dictionary new ]
]

{ #category : #accessing }
SLVMLLVMCodeGenerator >> debugCompileUnit [
	^ debugCompileUnit
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> debugTranslator [
	 ^ debugTranslator ifNil: [debugTranslator := SLVMLLVMDebugTranslator new moduleTranslator: self]
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> emptyDebugExpression [
	^ emptyDebugExpression ifNil: [ emptyDebugExpression := LLVMDIExpression for: self llvmModule ]
]

{ #category : #initialization }
SLVMLLVMCodeGenerator >> initialize [
	super initialize.
	translatedModuleElements := IdentityDictionary new.
	translatedTypes := IdentityDictionary new.
	translatedConstants := IdentityDictionary new.
	usedNames := Set new.
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> isEmittingDebugInformation [
	^ target emittingDebugInformation
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> llvmModule [
	^ llvmModule ifNil: [ llvmModule := LLVMModule name: #module context: self context ]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> newFunctionCodeGenerator [
	^ SLVMLLVMFunctionCodeGenerator new
		target: target;
		moduleTranslator: self;
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> recursiveType: type translationDo: aBlock [
	| incomplete result |
	incomplete := LLVMIncompleteType new.
	translatedTypes at: type put: incomplete.
	
	result := aBlock value.
	incomplete becomeForward: result.
	^ result
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> register: value debugElement: debugElement [
	self translatedDebugElements at: value put: debugElement
]

{ #category : #accessing }
SLVMLLVMCodeGenerator >> target [
	^ target
]

{ #category : #accessing }
SLVMLLVMCodeGenerator >> target: anObject [
	target := anObject
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateConstant: aConstant [
	^ translatedConstants at: aConstant ifAbsentPut: [ aConstant accept: self ]
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> translateDebugType: type [
	self translatedDebugElements at: type ifPresent: [ :existent | ^ existent ].
	^ self debugTranslator translate: type

]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateModule: module exportList: exportList [
	self translateModuleDebugInformation: module.

	module structures do: [ :structures |
		self translateNamedStructure: structures
	].

	exportList do: [ :value |
		self translateModuleElement: value
	].
	^ self llvmModule
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateModuleDebugInformation: module [
	| cuMetadata int32Ty |
	target emittingDebugInformation ifFalse: [ ^ self ].
	
	cuMetadata := LLVMMDTuple named: #'llvm.dbg.cu' for: self llvmModule.
	int32Ty := self context int32Ty.
	self llvmModule
		addModuleFlag: 'Dwarf Version' value: (int32Ty constant: 4) behaviorOnCollision: (int32Ty constant: 2);
		addModuleFlag: 'Debug Info Version' value: (int32Ty constant: 3) behaviorOnCollision: (int32Ty constant: 2).
	
	debugCompileUnit := (LLVMDICompileUnit for: self llvmModule)
		distinct;
		language: DW_LANG_lo_user value;
		producer: 'SLVM to LLVM';
		file: (self unknownDebugFile)
		yourself.

	cuMetadata elements: { debugCompileUnit }.
		
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateModuleElement: value [
	translatedModuleElements at: value ifPresent: [ :existent | ^ existent ].
	^ value accept: self
]

{ #category : #'as yet unclassified' }
SLVMLLVMCodeGenerator >> translateNamedStructure: aNamedStructure [
	| convertedStructure |
	convertedStructure := LLVMStructType new
		context: self context;
		name: ('%' , aNamedStructure name);
		yourself.
	translatedTypes at: aNamedStructure put: convertedStructure.
	self llvmModule addNamedStructure: convertedStructure.
	self convertStructureContent: aNamedStructure into: convertedStructure
	
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> translateType: aType [
	translatedTypes at: aType ifPresent: [ :existent | ^ existent ].
	^ aType accept: self
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateValue: aValue [
	aValue isGlobalValue ifTrue: [ ^ self translateModuleElement: aValue ].
	aValue isConstant ifTrue: [ ^ self translateConstant: aValue ].
	self error: 'Cannot translate value ', aValue printString
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> translatedDebugElements [
	^ translatedDebugElements ifNil: [ translatedDebugElements := Dictionary new ]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> type: type translationDo: aBlock [
	| result |
	result := aBlock value.
	translatedTypes at: type put: result.
	^ result
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> unknownDebugFile [
	^ unknownDebugFile ifNil: [ unknownDebugFile := (LLVMDIFile for: self llvmModule)
			filename: 'unknown';
			directory: '';
			yourself ]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitArrayType: type [
	^ self type: type translationDo: [ 
		LLVMArrayType get: (self translateType: type baseType) elements: type elements
	]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitBoolType: type [
	^ self type: type translationDo: [ self context int1Ty ]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantArrayBlob: constant [
	| type |
	type := self translateType: (constant type addCount: constant hasExtraNullCharacter asBit).
	^ LLVMConstantDataArray new type: type;
		elements: constant data;
		addNull: constant hasExtraNullCharacter ;
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantPointer: constant [
	| type variable pointedValue indexType |
	type := self translateType: constant type.
	pointedValue := self translateConstant: constant constant.
	
	variable := LLVMGlobalVariable createWithType: pointedValue type module: self llvmModule isConstant: true linkage: LLVMGlobalValue privateLinkage.
	variable
		alignment: constant constant type alignment;
		initialValue: pointedValue.
	
	indexType := type context int32Ty.
	^ LLVMGetElementPtrConstantExpr new
		type: type;
		pointer: variable;
		inbounds: true;
		indices: { indexType zeroConstant . indexType zeroConstant };
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantStructureValue: constantStructureValue [
	| type slots |
	type := self translateType: constantStructureValue type.
	slots := constantStructureValue slots collect: [ :slot | self translateValue: slot ].
	^ LLVMConstantStruct new
		type: type;
		elements: slots;
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantValue: aConstantValue [
	| type |
	type := self translateType: aConstantValue type.
	aConstantValue type isBooleanType ifTrue: [ ^ LLVMConstantInt new type: type; value: aConstantValue asBit ].
	type isIntegerTy ifTrue: [ ^ LLVMConstantInt new type: type; value: aConstantValue value ].
	type isFloatingPointTy ifTrue: [ ^ LLVMConstantFP new type: type; value: aConstantValue value ].
	type isPointerTy ifTrue: [ 
		(aConstantValue value = 0 or: [ aConstantValue value isNil ]) ifTrue: [ 
			^ LLVMConstantPointerNull new type: type
		].
	].
	self error: 'Unsupported constant value type'
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitFloatType: type [
	type size = 2 ifTrue: [ ^ self context halfTy ].
	type size = 4 ifTrue: [ ^ self context floatTy ].
	type size = 8 ifTrue: [ ^ self context doubleTy ].
	self error: 'Unsupported float type'
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitFunction: aFunction [
	| functionType function debugScope |
	functionType := self translateType: aFunction functionType.
	function := LLVMFunction createWithType: functionType linkage: (self convertLinkage: aFunction) name: (self convertName: aFunction name) module: self llvmModule.
	translatedModuleElements at: aFunction put: function.
	debugScope := self buildFunction: aFunction debugInformationInto: function.
	
	aFunction isEmpty ifFalse: [ 
		self newFunctionCodeGenerator
			functionDebugScope: debugScope;
			generateFunction: aFunction into: function
	].
	
	^ function
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitFunctionType: functionType [
	| returnType arguments |
	^ self recursiveType: functionType translationDo: [ 
		returnType := self translateType: functionType returnType.
		arguments := functionType arguments collect: [ :arg | self translateType: arg ].
		LLVMFunctionType get: returnType params: arguments isVarArg: functionType variadic
	]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitIntegerType: type [
	^ self type: type translationDo: [ 
		LLVMIntegerType get: self context bits: type size * 8
	]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitMatrixType: type [
	| columnType |
	^ self type: type translationDo: [
		columnType := self translateType: type columnType.
		LLVMStructType context: self context elements: ((1 to: type rows) collect: [:i | columnType])
	]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitPointerType: type [
	^ self recursiveType: type translationDo: [
		LLVMPointerType getUnqual: (self translateType: type baseType)
	]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitStructureType: structureType [
	self halt.
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitVectorType: type [
	^ self type: type translationDo: [
		LLVMVectorType get: (self translateType: type baseType) elements: type elements
	]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitVoidType: type [
	^ self context voidTy
]

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
		'emptyDebugExpression',
		'debugAnonymousCount',
		'translatedLiterals',
		'translatedCompiledMethodMetadata',
		'moduleDynamicRoots',
		'dynamicsRootsDescriptorVar',
		'objectMethodDispatchTrampolines',
		'nativeMethodDispatchTrampolines',
		'namedStructures',
		'compactTranslatedVectors',
		'cskMD5'
	],
	#classVars : [
		'DebugLanguageMap',
		'ThreadLocalModelMap'
	],
	#pools : [
		'SAsmDWConstants'
	],
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #'class initialization' }
SLVMLLVMCodeGenerator class >> initialize [
	DebugLanguageMap := Dictionary newFromPairs: { 
		'C' . DW_LANG_C.
		'C++' . DW_LANG_C_plus_plus.
	}.
	
	ThreadLocalModelMap := Dictionary newFromPairs: {
		#generalDynamicTLSModel . LLVMGlobalValue generalDynamicTLSModel
	}.
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> buildFunction: slvmFunction debugInformationInto: llvmFunction [
	| subprogram debugFile |
	(self isEmittingDebugInformation not or: [slvmFunction hasProperty: #omitDebugInformation]) ifTrue: [ ^ nil ].
	slvmFunction isEmpty ifTrue: [ ^ nil ].
	
	slvmFunction debugInformation ifNotNil: [ :debugInfo |
		subprogram := self translateDebugInformationElement: debugInfo
	] ifNil: [
		 subprogram := (LLVMDISubprogram for: llvmModule)
			distinct;
			scope: debugCompileUnit;
			unit: debugCompileUnit;
			isLocal: (slvmFunction isPublic or: [ slvmFunction isExternal ]) not;
			isDefinition: true;
			type: (self translateDebugType: slvmFunction debugType);
			retainedNodes: (LLVMMDDynamicTuple for: llvmModule)
			yourself.
			
		slvmFunction name ifNotNil: [ 
			(slvmFunction unmangledName isNotNil and: [slvmFunction unmangledName ~= slvmFunction name]) ifTrue: [
				subprogram name: (slvmFunction unmangledName)
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
	].
	
	slvmFunction name ifNotNil: [
		slvmFunction debugInformation ifNotNil: [ :debugInfo |
			debugInfo emitLinkageName ifTrue: [ 
				subprogram linkageName: slvmFunction name
			].
		]
	].

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

	llvmFunction addDebugMetadata: subprogram.
	
	"slvmFunction arguments doWithIndex: [ :arg :index |
		arg debugInformation ifNotNil: [
			self createArgument: arg index: index debugInformationInto: subprogram.
		].
	]."

	^ subprogram
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> buildGlobalVariable: slvmGlobalVariable debugInformationInto: variable [
	| debugGlobalVariable debugFile debugGlobalVariableExpression debugInfo |
	(self isEmittingDebugInformation not or: [slvmGlobalVariable hasProperty: #omitDebugInformation]) ifTrue: [ ^ nil ].
	debugInfo := slvmGlobalVariable debugInformation ifNil: [ ^ nil ].
	
	debugGlobalVariable := (LLVMDIGlobalVariable for: llvmModule)
		distinct;
		name: debugInfo name;
		yourself.
		
	self translatedDebugElements at: debugInfo put: debugGlobalVariable.
	debugGlobalVariable
		scope: (self convertDebugScope: debugInfo scope fallbackTo: debugCompileUnit);
		isLocal: (slvmGlobalVariable isPublic or: [ slvmGlobalVariable isExternal ]) not;
		isDefinition: slvmGlobalVariable isExternal not;
		type: (self translateDebugType: (debugInfo type ifNil: [slvmGlobalVariable valueType])).
	
	slvmGlobalVariable debugSourceLocation ifNotNil: [ :sourceLocation |
		debugFile := self convertDebugFile: sourceLocation sourceFile.
		debugGlobalVariable
			file: debugFile;
			line: sourceLocation startLine.
			
		debugGlobalVariable scope == debugCompileUnit ifTrue: [ 
			debugGlobalVariable scope: debugFile
		].
	].

	debugGlobalVariableExpression := (LLVMDIGlobalVariableExpression for: llvmModule)
		var: debugGlobalVariable;
		expr: (LLVMDIExpression for: llvmModule);
		yourself.
	variable addDebugMetadata: debugGlobalVariableExpression.
	
	debugCompileUnit globals ifNil: [ debugCompileUnit globals: (LLVMMDDynamicTuple for: llvmModule) ].
	debugCompileUnit globals addElement: debugGlobalVariableExpression.
	
	^ debugGlobalVariable
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> context [
	^ llvmContext ifNil: [ llvmContext := LLVMContext new ]
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> convertDebugFile: debugFile [
	^ self convertedDebugFiles at: debugFile ifAbsentPut: [
		self isEmittingCodeView ifTrue: [ 
			(LLVMDIFile for: self llvmModule)
				filename: debugFile fullname;
				directory: '';
				checksumkind: self cskMD5;
				checksum: debugFile md5Checksum;
				yourself
		] ifFalse: [ 
			(LLVMDIFile for: self llvmModule)
				filename: debugFile name;
				directory: debugFile directory;
				yourself
		].
	]
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> convertDebugScope: scope fallbackTo: fallbackScope [
	scope ifNil: [ ^ fallbackScope ].
	^ self translateDebugInformationElement: scope
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
	element name ifNil: [ 
		^ LLVMGlobalValue privateLinkage
	].

	element isLinkOnceODR ifTrue: [ 
		^ LLVMGlobalValue linkOnceODRLinkage
	].
	element isWeakODR ifTrue: [ 
		^ LLVMGlobalValue weakODRLinkage
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
	slvmStructure isUnionType ifTrue: [ 
		llvmStructure elements: (self translateUnionTypes: slvmStructure types size: slvmStructure size alignment: slvmStructure alignment)
	] ifFalse: [ 
		llvmStructure elements: (self translateStructureFieldTypes: slvmStructure)
	]

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

{ #category : #visiting }
SLVMLLVMCodeGenerator >> createComdatIfRequiredFor: aGlobal [
	| comdat |
	aGlobal name ifNil: [ ^ self ].
	self target isWindows ifFalse: [ ^ self ].

	(aGlobal linkage = LLVMGlobalValue linkOnceODRLinkage
	or: [aGlobal linkage = LLVMGlobalValue weakODRLinkage]) ifTrue: [
		comdat := LLVMComdat new
			name: aGlobal name; 
			type: #any.
		llvmModule addComdat: comdat.
		aGlobal comdat: comdat.
	].

]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> createDoesNotUnderstandTrampolineWithType: functionType [
	| slvmFunction |
	slvmFunction := target objectModel createDoesNotUnderstandTrampolineWithType: functionType.
	^ self translateValue: slvmFunction
]

{ #category : #'as yet unclassified' }
SLVMLLVMCodeGenerator >> createGlobalDynamicRootsCtor [
	| descriptorVar ctorFunction bb moduleRootRegistrationFunction descriptorPointer descriptorCount |
	descriptorVar := self getOrCreateDynamicsRootsDescriptor.
	moduleRootRegistrationFunction := self translateValue: self target objectModel moduleRootRegistrationFunction.
	descriptorPointer := LLVMBitCastConstantExpr new
		type: moduleRootRegistrationFunction functionType params first;
		source: descriptorVar;
		yourself.
	descriptorCount := moduleRootRegistrationFunction functionType params second constant: descriptorVar valueType elements.
	
	ctorFunction := LLVMFunction createWithType: (LLVMFunctionType get: self context voidTy params: #() isVarArg: false) linkage: LLVMGlobalValue privateLinkage name: nil module: self llvmModule..
	bb := LLVMBasicBlock for: self context name: #entry parent: ctorFunction.
	(LLVMIRBuilder forBasicBlock: bb)
		call: moduleRootRegistrationFunction arguments: { descriptorPointer . descriptorCount};
		returnVoid.
	^ ctorFunction
]

{ #category : #'as yet unclassified' }
SLVMLLVMCodeGenerator >> createGlobalDynamicRootsCtorOrDtorFor: llvmGlobalName [
	self assert: llvmGlobalName = #'llvm.global_ctors'.
	^ self createGlobalDynamicRootsCtor
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> createNativeMethodDispatchTrampolineWithType: functionType [
	| slvmFunction |
	slvmFunction := target objectModel createNativeMethodDispatchTrampolineWithType: functionType.
	^ self translateValue: slvmFunction
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> createObjectMethodDispatchTrampolineWithType: functionType [
	| slvmFunction |
	slvmFunction := target objectModel createObjectMethodDispatchTrampolineWithType: functionType.
	^ self translateValue: slvmFunction
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> cskMD5 [
	^ cskMD5 ifNil: [cskMD5 := LLVMNamedFlags with: #(CSK_MD5)]
]

{ #category : #accessing }
SLVMLLVMCodeGenerator >> debugCompileUnit [
	^ debugCompileUnit
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> debugTranslator [
	 ^ debugTranslator ifNil: [debugTranslator := SLVMLLVMDebugTranslator new moduleTranslator: self]
]

{ #category : #'as yet unclassified' }
SLVMLLVMCodeGenerator >> declareNamedStructure: aNamedStructure [
	| convertedStructure |
	convertedStructure := LLVMStructType new
		context: self context;
		name: ('%' , aNamedStructure name llvmNameString);
		packed: aNamedStructure isPacked;
		yourself.
	translatedTypes at: aNamedStructure put: convertedStructure.
	namedStructures at: aNamedStructure name ifPresent: [ self error ] ifAbsentPut: convertedStructure.
	self llvmModule addNamedStructure: convertedStructure.
	^ convertedStructure
	
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> emptyDebugExpression [
	^ emptyDebugExpression ifNil: [ emptyDebugExpression := LLVMDIExpression for: self llvmModule ]
]

{ #category : #initialization }
SLVMLLVMCodeGenerator >> generateDebugAnonymousName [
	debugAnonymousCount := debugAnonymousCount + 1.
	^ '__anonymous' , debugAnonymousCount asString
]

{ #category : #'as yet unclassified' }
SLVMLLVMCodeGenerator >> getOrCreateDynamicsRootsDescriptor [
	| dynamicInstanceRoots dynamicPointerRoots voidPointerTy uintPointerTy rootPointerDescriptor dynamicInstanceRootArrayType dynamicInstanceRootConstant dynamicInstanceRootGlobal pointerRootsArrayType pointerRootsConstant |
	dynamicsRootsDescriptorVar ifNotNil: [ ^ dynamicsRootsDescriptorVar ].
	
	voidPointerTy := LLVMPointerType getUnqual: self context int8Ty.
	uintPointerTy := self target pointerSize = 4 ifTrue: [ self context int32Ty ] ifFalse: [ self context int64Ty ].
	
	rootPointerDescriptor := LLVMStructType context: self context elements: { voidPointerTy . uintPointerTy }.
	
	dynamicInstanceRoots := OrderedCollection new.
	dynamicPointerRoots := OrderedCollection new.
	moduleDynamicRoots do: [ :each |
		| castedPointer |
		castedPointer := LLVMBitCastConstantExpr new type: voidPointerTy; source: each; yourself.
		each valueType isPointerTy ifTrue: [ 
			dynamicPointerRoots add: (rootPointerDescriptor constant: {castedPointer . uintPointerTy constant: 1}).
		] ifFalse: [
			each valueType isArrayTy ifTrue: [
				dynamicPointerRoots add: (rootPointerDescriptor constant: {castedPointer . uintPointerTy constant: each valueType totalElementCount}).
			] ifFalse: [ 
				self assert: each valueType isStructTy.
				dynamicInstanceRoots add: castedPointer.
			].
		].
	].

	"Create a root array with pointers to all the instances."
	dynamicInstanceRootArrayType := LLVMArrayType get: voidPointerTy elements: dynamicInstanceRoots size.
	dynamicInstanceRootConstant := dynamicInstanceRootArrayType constant: dynamicInstanceRoots.
	dynamicInstanceRootGlobal := LLVMGlobalVariable createWithType: dynamicInstanceRootArrayType module: self llvmModule isConstant: false linkage: LLVMGlobalValue privateLinkage.
	dynamicInstanceRootGlobal initialValue: dynamicInstanceRootConstant.
	
	"Create the descritor for the instances roots."
	dynamicPointerRoots add: (rootPointerDescriptor constant: {
		LLVMBitCastConstantExpr new type: voidPointerTy; source: dynamicInstanceRootGlobal; yourself .
		uintPointerTy constant: dynamicInstanceRoots size
	}).

	pointerRootsArrayType := LLVMArrayType get: rootPointerDescriptor elements: dynamicPointerRoots size.
	pointerRootsConstant := pointerRootsArrayType constant: dynamicPointerRoots.
	dynamicsRootsDescriptorVar := LLVMGlobalVariable createWithType: pointerRootsArrayType module: self llvmModule isConstant: false linkage: LLVMGlobalValue privateLinkage.
	dynamicsRootsDescriptorVar initialValue: pointerRootsConstant.
	^ dynamicsRootsDescriptorVar
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> getOrCreateRuntimeFunction: runtimeFunctionOrSymbol type: typeDefinition [
	runtimeFunctionOrSymbol isSymbol ifTrue: [ 
		self halt.
	].

	^ self translateValue: runtimeFunctionOrSymbol
]

{ #category : #initialization }
SLVMLLVMCodeGenerator >> initialize [
	super initialize.
	translatedModuleElements := IdentityDictionary new.
	namedStructures := Dictionary new.
	compactTranslatedVectors := Dictionary new.
	translatedTypes := IdentityDictionary new.
	translatedConstants := IdentityDictionary new.
	translatedLiterals := IdentityDictionary new.
	translatedCompiledMethodMetadata := IdentityDictionary new.
	objectMethodDispatchTrampolines := Dictionary new.
	nativeMethodDispatchTrampolines := Dictionary new.
	usedNames := Set new.
	moduleDynamicRoots := OrderedCollection new.
	debugAnonymousCount := 0.
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> intPointerType [
	^ target pointerSize = 4 ifTrue: [ llvmContext int32Ty ] ifFalse: [ llvmContext int64Ty ]
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> isEmittingCodeView [
	^ target isWindows
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> isEmittingDebugInformation [
	^ target emittingDebugInformation
]

{ #category : #accessing }
SLVMLLVMCodeGenerator >> isInliningMandatory [
	^ false
]

{ #category : #testing }
SLVMLLVMCodeGenerator >> isSpecialSetjmp: aFunction [
	^ target isWindows and: [
	(aFunction isFunction) and: [
	#(_setjmp __setjmp) includes: aFunction name]]
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> llvmModule [
	^ llvmModule ifNil: [ llvmModule := (LLVMModule name: #module context: self context)
			optimizationLevel: optimizationLevel;
			relocationModel: target relocationModel;
			targetTriple: target targetTriple;
			linkerTargetTriple: target linkerTargetTriple;
			machineAttributes: target machineAttributes;
			compilationPlugins: target compilationPlugins;
			cpu: target cpu;
			fpu: target fpu;
			floatAbiName: target floatAbiName;
			floatingPointModel: target floatingPointModel;
			exceptionModel: target exceptionModel;
			yourself
		]
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> nativeMethodDispatchTrampolineWithType: trampolineFunctionType [
	^ nativeMethodDispatchTrampolines at: trampolineFunctionType ifAbsentPut: [ self createNativeMethodDispatchTrampolineWithType: trampolineFunctionType]
]

{ #category : #testing }
SLVMLLVMCodeGenerator >> needStructuredControlFlow [
	^ false
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> newFunctionCodeGenerator [
	^ SLVMLLVMFunctionCodeGenerator new
		target: target;
		moduleTranslator: self;
		yourself
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> objectMethodDispatchTrampolineForWithType: trampolineFunctionType [
	^ objectMethodDispatchTrampolines at: trampolineFunctionType ifAbsentPut: [ self createObjectMethodDispatchTrampolineWithType: trampolineFunctionType]
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

{ #category : #visiting }
SLVMLLVMCodeGenerator >> setLLVMFunction: llvmFunction flagsFrom: slvmFunction [
	slvmFunction arguments doWithIndex: [ :arg :index |
		| llvmArgument |
		llvmArgument := llvmFunction arguments at: index.
		arg isStructReturnPointer ifTrue: [ llvmArgument addFlag: #sret; addFlag: #noalias ].
		arg type isIntegerType ifTrue: [ 
			arg type isSigned ifTrue: [
				llvmArgument addFlag: #signext
			] ifFalse: [ 
				llvmArgument addFlag: #zeroext
			]
		].
	].

	slvmFunction returnType isIntegerType ifTrue: [ 
		slvmFunction returnType isSigned ifTrue: [ 
			llvmFunction addReturnAttribute: #signext
		] ifFalse: [ 
			llvmFunction addReturnAttribute: #zeroext
		]
	].

	slvmFunction isNoUnwind ifTrue: [ 
		llvmFunction addFunctionAttribute: #nounwind
	].
	slvmFunction isNoReturn ifTrue: [ 
		llvmFunction addFunctionAttribute: #noreturn
	].
	slvmFunction doesHaveMultipleReturns ifTrue: [ 
		llvmFunction addFunctionAttribute: #returns_twice
	].

	slvmFunction isEmpty ifFalse: [
		slvmFunction hasYesInlineMode ifTrue: [ 
			llvmFunction addFunctionAttribute: #inlinehint
		]. 
		slvmFunction hasNeverInlineMode ifTrue: [ 
			llvmFunction addFunctionAttribute: #noinline
		]. 
		slvmFunction hasAlwaysInlineMode ifTrue: [ 
			llvmFunction addFunctionAttribute: #alwaysinline
		]. 
	]
]

{ #category : #accessing }
SLVMLLVMCodeGenerator >> target [
	^ target
]

{ #category : #accessing }
SLVMLLVMCodeGenerator >> target: anObject [
	target := anObject
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> translateCompactVersionOf: type [
	self assert: type isVectorType.
	^ compactTranslatedVectors at: type ifAbsentPut: [
		| elementType |
		elementType := self translateType: type baseType.
		LLVMArrayType get: elementType elements: type elements
	]

]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateCompiledMethodMetadataOf: aFunction [
	| metadata |
	translatedCompiledMethodMetadata at: aFunction ifPresent: [ :existent | ^ existent ].
	
	metadata := self translateDynamicLiteral: (target objectModel createFunctionContextMetaData: aFunction).
	translatedCompiledMethodMetadata at: aFunction put: metadata.
	^ metadata
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateConstant: aConstant [
	^ translatedConstants at: aConstant ifAbsentPut: [ aConstant accept: self ]
]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> translateDebugInformationElement: element [
	self translatedDebugElements at: element ifPresent: [ :existent | ^ existent ].
	^ self debugTranslator translate: element

]

{ #category : #'debug information' }
SLVMLLVMCodeGenerator >> translateDebugType: type [
	^ self translateDebugInformationElement: type
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateDynamicLiteral: aLiteral [
	| literalConstantValue llvmConstant variable literalVariable encodedLiteral |
	(target objectModel isInlineLiteral: aLiteral) ifTrue: [ 
		encodedLiteral := target objectModel encodeInlineLiteral: aLiteral.
		^ self translateValue: encodedLiteral
	].

	translatedLiterals at: aLiteral ifPresent: [ :existent | ^ existent ].
	
	literalVariable := target objectModel createNonInlineLiteralUniqueGlobal: aLiteral withCodeGenerator: self.
	literalVariable ifNotNil: [
		variable := self translateValue: literalVariable.
		translatedLiterals at: aLiteral put: variable.
		^ variable
	].
	
	literalConstantValue := target objectModel createNonInlineLiteralConstant: aLiteral withCodeGenerator: self.
	
	llvmConstant := self translateConstant: literalConstantValue.

	variable := LLVMGlobalVariable createWithType: llvmConstant type module: self llvmModule isConstant: true linkage: LLVMGlobalValue privateLinkage.
	variable
		alignment: target objectModel objectAlignment;
		initialValue: llvmConstant.
	moduleDynamicRoots add: variable.
	
	translatedLiterals at: aLiteral put: variable.
	^ variable

]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateModule: module exportList: exportList [
	self applyPassesIn: module functionList: (exportList select: [:each | each isFunction]).
	self translateModuleDebugInformation: module.
	
	module structures do: [ :structures |
		self declareNamedStructure: structures
	].

	module structures do: [ :structures |
		self translateNamedStructure: structures
	].

	module inlineAssemblyFragments do: [ :assemblyFragments |
		self translateModuleInlineAssembly: assemblyFragments
	].

	exportList do: [ :value |
		self translateModuleElement: value
	].

	self translateModuleConstructorsOrDestructors: module globalConstructors name: #'llvm.global_ctors'.
	self translateModuleConstructorsOrDestructors: module globalDestructors name: #'llvm.global_dtors'.
	^ self llvmModule
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateModuleConstructorsOrDestructors: constructorsOrDestructors name: llvmGlobalName [
	| ctorFunctionType ctorFunctionPointerType int32Ty varPointerType descriptorType descriptors descriptorsType variable |
	ctorFunctionType := LLVMFunctionType get: self context voidTy params: #() isVarArg: false.
	ctorFunctionPointerType := LLVMPointerType getUnqual: ctorFunctionType.
	int32Ty := llvmContext int32Ty.
	varPointerType := LLVMPointerType getUnqual: llvmContext int8Ty.
	
	descriptorType := LLVMStructType context: llvmContext elements: { int32Ty . ctorFunctionPointerType . varPointerType }.
	descriptors := constructorsOrDestructors collect: [ :desc |
		descriptorType constant: {
			int32Ty constant: desc priority .
			self translateModuleElement: desc function .
			desc global
				ifNil: [ LLVMConstantPointerNull new type: varPointerType ]
				ifNotNil: [ LLVMBitCastConstantExpr new
					type: varPointerType;
					source: (self translateModuleElement: desc global);
					yourself ]
		}
	].

	(moduleDynamicRoots isNotEmpty and: [llvmGlobalName = 'llvm.global_ctors' ]) ifTrue: [
		(self createGlobalDynamicRootsCtorOrDtorFor: llvmGlobalName) ifNotNil: [ :ctorOrDtor |
			descriptors add: (descriptorType constant: {
				int32Ty constant: self target objectModel gcModuleRootRegistrationPriority .
				ctorOrDtor .
				LLVMBitCastConstantExpr new type: varPointerType; source: dynamicsRootsDescriptorVar; yourself
			})
		].
	].

	descriptors ifEmpty: [ ^ self ].
	descriptorsType := LLVMArrayType get: descriptorType elements: descriptors size.
	
	variable := LLVMGlobalVariable createWithType: descriptorsType module: self llvmModule isConstant: false linkage: LLVMGlobalValue appendingLinkage name: llvmGlobalName.
	variable initialValue: (LLVMConstantArray new
		type: descriptorsType;
		elements: descriptors;
		yourself)

]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateModuleDebugInformation: module [
	| cuMetadata int32Ty |
	target emittingDebugInformation ifFalse: [ ^ self ].
	
	cuMetadata := LLVMMDTuple named: #'llvm.dbg.cu' for: self llvmModule.
	int32Ty := self context int32Ty.
	self isEmittingCodeView ifTrue: [
		self llvmModule
			addModuleFlag: 'CodeView' value: (int32Ty constant: 1) behaviorOnCollision: (int32Ty constant: 2)
		
	] ifFalse: [
		self llvmModule
			addModuleFlag: 'Dwarf Version' value: (int32Ty constant: 4) behaviorOnCollision: (int32Ty constant: 2)
	].

	self llvmModule
		addModuleFlag: 'Debug Info Version' value: (int32Ty constant: 3) behaviorOnCollision: (int32Ty constant: 2).
	
	debugCompileUnit := (LLVMDICompileUnit for: self llvmModule)
		distinct;
		language: (DebugLanguageMap at: module sourceLanguageName ifAbsent: [DW_LANG_lo_user value]);
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

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateModuleInlineAssembly: assemblyFragment [
	"Only support gas syntax for now."
	assemblyFragment language ~~ #gas ifTrue: [^ self].
	
	llvmModule addModuleLevelInlineAssembly: assemblyFragment source
]

{ #category : #'as yet unclassified' }
SLVMLLVMCodeGenerator >> translateNamedStructure: aNamedStructure [
	| convertedStructure |
	convertedStructure := translatedTypes at: aNamedStructure.
	self convertStructureContent: aNamedStructure into: convertedStructure
	
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> translateSpecialSetjmp: aFunction [
	| functionType intrinsicName function |
	target isX86_32 ifTrue: [
		intrinsicName := #_setjmp3.
		functionType := LLVMFunctionType get: self context int32Ty params: {LLVMPointerType getUnqual: self context int8Ty . self context int32Ty} isVarArg: false.
	].

	target isX86_64 ifTrue: [ 
		intrinsicName := #_setjmp.
		functionType := LLVMFunctionType get: self context int32Ty params: {LLVMPointerType getUnqual: self context int8Ty . LLVMPointerType getUnqual: self context int8Ty} isVarArg: false.
	].

	functionType ifNil: [
		self error: 'Case not yet supported.'
	].

	function := LLVMFunction createWithType: functionType linkage: LLVMGlobalValue externalLinkage name: intrinsicName module: self llvmModule.
	function addFunctionAttribute: #returns_twice.
	translatedModuleElements at: aFunction put: function.
	self buildFunction: aFunction debugInformationInto: function.
	
	^ function

]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> translateStructureFieldTypes: structureType [
	| currentOffset fieldTypes |
	currentOffset := 0.

	fieldTypes := OrderedCollection new.

	structureType types doWithIndex: [ :type :i |
		| currentTypeSize currentTypeAlignedSize fieldConvertedType nextOffset |
		currentOffset := currentOffset alignedTo: type alignment.
		currentTypeSize := type size.
		currentTypeAlignedSize := currentTypeSize alignedTo: type alignment.

		fieldConvertedType := self translateType: type.
		nextOffset := currentOffset + currentTypeAlignedSize.
		(type size < type alignment and: [ i + 1 <= structureType types size ]) ifTrue: [
			| nextType nextUnalignedSize |
			nextType := structureType types at: i + 1.
			nextUnalignedSize := currentOffset + currentTypeSize.
			(nextUnalignedSize + nextType size) = nextOffset ifTrue: [
				fieldConvertedType := self translateCompactVersionOf: type.
				nextOffset := nextUnalignedSize.
			].
		].
	
		currentOffset := nextOffset.
		fieldTypes add: fieldConvertedType.
	].

	^ fieldTypes asArray.

]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> translateType: aType [
	translatedTypes at: aType ifPresent: [ :existent | ^ existent ].
	^ aType accept: self
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> translateUnionTypes: types size: unionSize alignment: unionAlignment [
	| alignedUnionSize typeWithBestAlignment remainingSize translatedTypeWithBestAlignment |
	alignedUnionSize := unionSize alignedTo: unionAlignment.
	typeWithBestAlignment := types first.
	types do: [ :each |
		each alignment > typeWithBestAlignment alignment ifTrue: [
			typeWithBestAlignment := each
		]
	].
	
	remainingSize := alignedUnionSize - typeWithBestAlignment size.
	translatedTypeWithBestAlignment := self translateType: typeWithBestAlignment.
	remainingSize = 0 ifTrue: [ ^ { translatedTypeWithBestAlignment } ].
	self assert: remainingSize > 0.
	^ { translatedTypeWithBestAlignment . LLVMArrayType get: self context int8Ty elements: remainingSize }
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateValue: aValue [
	aValue isGlobalValue ifTrue: [ ^ self translateModuleElement: aValue ].
	aValue isConstant ifTrue: [ ^ self translateConstant: aValue ].
	self error: 'Cannot translate value ', aValue printString
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> translateValue: value withExpectedType: expectedValueType [
	| result |
	result := self translateValue: value.
	result type ~= expectedValueType ifTrue: [ 
		(result type isVectorTy and: [ expectedValueType isArrayTy ]) ifTrue: [
			^ result convertIntoCompactVectorType: expectedValueType
		]
	].

	^ result
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

{ #category : #visiting }
SLVMLLVMCodeGenerator >> uintPointerType [
	^ target pointerSize = 4 ifTrue: [ llvmContext int32Ty ] ifFalse: [ llvmContext int64Ty ]
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> unknownDebugFile [
	^ unknownDebugFile ifNil: [
		self isEmittingCodeView ifTrue: [
			unknownDebugFile := (LLVMDIFile for: self llvmModule)
				filename: 'unknown';
				directory: '';
				checksumkind: self cskMD5;
				checksum: (MD5 hashMessage: #[]) hex;
				yourself
		] ifFalse: [
			unknownDebugFile := (LLVMDIFile for: self llvmModule)
				filename: 'unknown';
				directory: '';
				yourself
		].
	]
]

{ #category : #testing }
SLVMLLVMCodeGenerator >> usesGCStrategy [
	^ true
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitArrayType: type [
	^ self type: type translationDo: [ 
		LLVMArrayType get: (self translateType: type baseType) elements: type validElements
	]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitBoolType: type [
	^ self type: type translationDo: [ self context int1Ty ]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitClosureDefinition: closureDefinition [
	| prototype prototypeValue |
	prototype := self target objectModel constructClosurePrototypeFor: closureDefinition.
	prototypeValue := self translateValue: prototype.
	
	(self target objectModel isClosureKindAllocatedInTheStack: closureDefinition kind) ifFalse: [ 
		prototypeValue := (LLVMGlobalVariable createWithType: prototypeValue type module: self llvmModule isConstant: true linkage: LLVMGlobalValue privateLinkage)
			alignment: prototype type alignment;
			initialValue: prototypeValue.
	].
	^ prototypeValue
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
SLVMLLVMCodeGenerator >> visitConstantArrayValue: constantStructureValue [
	| type slots |
	type := self translateType: constantStructureValue type.
	slots := constantStructureValue slots collect: [ :slot | self translateValue: slot ].
	^ LLVMConstantArray new
		type: type;
		elements: slots;
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantCompiledMethodMetadata: compiledMethodMetadata [
	| metadata targetType |
	metadata := self translateCompiledMethodMetadataOf: compiledMethodMetadata sourceMethod.
	targetType := self translateType: compiledMethodMetadata type.
	targetType ~~ metadata type ifTrue: [
		^ LLVMBitCastConstantExpr new
			type: targetType;
			source: metadata;
			yourself
	].
	^ metadata
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantExpressionBitCast: constantBitCast [
	^ LLVMBitCastConstantExpr new
		type: (self translateType: constantBitCast type);
		source: (self translateValue: constantBitCast source);
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantExpressionGetElementPointer: aConstant [
	| type |
	type := self translateType: aConstant type.
	^ LLVMGetElementPtrConstantExpr new
		type: type;
		inbounds: aConstant inBounds;
		pointer: (self translateValue: aConstant pointer);
		indices: (aConstant indices collect: [:index | self translateValue: index]);
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantMatrixValue: constantMatrixValue [
	| type slots |
	type := self translateType: constantMatrixValue type.
	slots := constantMatrixValue slots collect: [ :slot | self translateValue: slot ].
	^ LLVMConstantStruct new
		type: type;
		elements: slots;
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantPointer: constant [
	| type variable pointedValue |
	type := self translateType: constant type.
	pointedValue := self translateConstant: constant constant.
	
	variable := LLVMGlobalVariable createWithType: pointedValue type module: self llvmModule isConstant: true linkage: LLVMGlobalValue privateLinkage.
	variable
		alignment: constant constant type alignment;
		initialValue: pointedValue.
	
	^ LLVMBitCastConstantExpr new
		type: type;
		source: variable;
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantStructureValue: constantStructureValue [
	| type slots |
	type := self translateType: constantStructureValue type.
	slots := constantStructureValue slots collectWithIndex: [ :slot :index |
		self translateValue: slot withExpectedType: (type elements at: index)
	].
	^ LLVMConstantStruct new
		type: type;
		elements: slots;
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantUndefined: aConstant [
	| type |
	type := self translateType: aConstant type.
	^ LLVMUndefValue new
		type: type;
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantUnionBlobValue: constantUnionValue [
	^ self visitConstantArrayBlob: constantUnionValue
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantValue: aConstantValue [
	| type resultValue |
	type := self translateType: aConstantValue type.
	aConstantValue type isDynamicObjectType ifTrue: [
		resultValue := self translateDynamicLiteral: aConstantValue value.
		resultValue type = type ifTrue: [ ^ resultValue ].
		self assert: type isPointerTy.
		resultValue type isIntegerTy ifTrue: [ ^ LLVMIntToPtrConstantExpr new type: type; source: resultValue; yourself ].
		resultValue type isPointerTy ifTrue: [ ^ LLVMBitCastConstantExpr new type: type; source: resultValue; yourself ].
		self error: 'Case not supported'.
	].
	
	aConstantValue type isBooleanType ifTrue: [ ^ LLVMConstantInt new type: type; value: aConstantValue value asBit ].
	type isIntegerTy ifTrue: [
		self assert: aConstantValue value isInteger.
		^ LLVMConstantInt new type: type; value: aConstantValue value
	].
	type isFloatingPointTy ifTrue: [ ^ type constantScalarValue: aConstantValue value ].
	type isPointerTy ifTrue: [ 
		(aConstantValue value = 0 or: [ aConstantValue value isNil ]) ifTrue: [ 
			^ LLVMConstantPointerNull new type: type
		].
	
		^ LLVMIntToPtrConstantExpr new
			type: type;
			source: (LLVMConstantInt new
				type: self intPointerType;
				value: aConstantValue value;
				yourself);
			yourself
	].
	self error: 'Unsupported constant value type'
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantVectorValue: constantVectorValue [
	| type slots |
	type := self translateType: constantVectorValue type.
	slots := constantVectorValue slots collect: [ :slot | self translateValue: slot ].
	^ LLVMConstantVector new
		type: type;
		elements: slots;
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantZeroInitializer: aConstant [
	| type |
	type := self translateType: aConstant type.
	^ LLVMConstantZeroInitializer new
		type: type;
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitDynamicObjectType: type [
	^ self recursiveType: type translationDo: [
		self flag: 'TODO: Change this for a pointer into an object header.'.
		LLVMPointerType getUnqual: self context int8Ty
	]
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
	(self isSpecialSetjmp: aFunction) ifTrue: [ 
		^ self translateSpecialSetjmp: aFunction
	].

	aFunction applyGCStrategy.

	functionType := self translateType: aFunction functionType.
	function := LLVMFunction createWithType: functionType linkage: (self convertLinkage: aFunction) name: (self convertName: aFunction name) module: self llvmModule.
	self createComdatIfRequiredFor: function.
	translatedModuleElements at: aFunction put: function.
		
	aFunction propertyAt: #llvmGCStrategy ifPresent: [ :gcStrategyName |
		function gcStrategy: gcStrategyName
	].

	aFunction personalityFunction ifNotNil: [ :pf |
		function personalityFunction: (self translateValue: pf)
	].

	debugScope := self buildFunction: aFunction debugInformationInto: function.
	
	self setLLVMFunction: function flagsFrom: aFunction.
	
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
SLVMLLVMCodeGenerator >> visitGlobalVariable: aGlobalVariable [
	| variableType variable |
	variableType := self translateType: aGlobalVariable valueType.
	variable := LLVMGlobalVariable createWithType: variableType module: self llvmModule isConstant: aGlobalVariable readOnly linkage: (self convertLinkage: aGlobalVariable) name: (self convertName: aGlobalVariable name) threadLocalMode: LLVMGlobalValue notThreadLocal addressSpace: 0.
	variable alignment: aGlobalVariable valueType alignment.
	self createComdatIfRequiredFor: variable.
	aGlobalVariable threadLocalModel ifNil: [ 
		aGlobalVariable type storage == SLVMType gcStorage ifTrue: [
			moduleDynamicRoots add: variable
		].
	] ifNotNil: [ :modelName |
		variable threadLocalMode: (ThreadLocalModelMap at: modelName)
	].
	aGlobalVariable minimalAlignment ifNotNil: [ :align |
		variable alignment: (variable alignment max: align)
	].

	translatedModuleElements at: aGlobalVariable put: variable.
	self buildGlobalVariable: aGlobalVariable debugInformationInto: variable.
	
	aGlobalVariable initialValue ifNotNil: [ :constant |
		variable initialValue: (self translateValue: constant)
	].

	^ variable
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
		LLVMStructType context: self context elements: ((1 to: type columns) collect: [:i | columnType])
	]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitPackedStructureType: structureType [
	structureType name ifNotNil: [ self halt ].
	^ self recursiveType: structureType translationDo: [
		(LLVMStructType context: llvmContext elements: (structureType types collect: [:type | self translateType: type]))
			packed: true
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
	structureType name ifNotNil: [
		| convertedStructure |
		"Duplicated structure may be because of multiple imported/linked modules"
		namedStructures at: structureType name ifPresent: [ :existentTranslation |
			translatedTypes at: structureType put: existentTranslation.
			^ existentTranslation
		].
	
		"Some trampolines may reach to this case."
		convertedStructure := self declareNamedStructure: structureType.
		self translateNamedStructure: structureType.
		^ convertedStructure
	].
	^ self recursiveType: structureType translationDo: [
		LLVMStructType context: llvmContext elements: (self translateStructureFieldTypes: structureType)
	]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitUnionType: type [
	^ self type: type translationDo: [
		
		LLVMStructType context: self context elements: (self translateUnionTypes: type types size: type size alignment: type alignment)
	]

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

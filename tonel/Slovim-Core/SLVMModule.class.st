"
I represent a SSA module that can contain named and unnamed elements. The elements in a module are global values.
"
Class {
	#name : #SLVMModule,
	#superclass : #SLVMObject,
	#instVars : [
		'compilationTarget',
		'packages',
		'classVariableClassMap',
		'debugInformation',
		'structures',
		'inlineAssemblyFragments',
		'globalConstructors',
		'globalDestructors',
		'currentOptimizationLevel',
		'highLevelMapToSymbol',
		'symbolMapToHighLevel',
		'sourceLanguageName',
		'disableSLVMOptimizations',
		'globalValueDictionary',
		'globalValues',
		'structureDictionary',
		'globalDecodeBaseIndex',
		'highLevelMapToStructureType',
		'structureTypeNameToHighLevelMap',
		'nonInlineLiterals',
		'nonInlineLiteralsTable'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #adding }
SLVMModule >> add: aGlobalValue [
	aGlobalValue module: self.
	globalValues add: aGlobalValue.
	aGlobalValue name ifNotNil: [ :name |
		globalValueDictionary at: name ifAbsentPut: aGlobalValue
	].

]

{ #category : #adding }
SLVMModule >> addArchitecture: architecture language: language inlineAssembly: assembly [
	inlineAssemblyFragments add: (SLVMGlobalInlineAssemblyFragment new
		architecture: architecture;
		language: language;
		source: assembly;
		yourself)
]

{ #category : #adding }
SLVMModule >> addGlobal: aGlobalVariable constructor: constructor [
	^ self addGlobal: aGlobalVariable constructor: constructor priority: 0
]

{ #category : #adding }
SLVMModule >> addGlobal: aGlobalVariable constructor: constructor priority: priority [
	globalConstructors add: (SLVMGlobalConstructorDestructorMetadata new
		global: aGlobalVariable;
		function: constructor;
		priority: priority;
		yourself)
]

{ #category : #adding }
SLVMModule >> addGlobal: aGlobalVariable destructor: destructor [
	^ self addGlobal: aGlobalVariable destructor: destructor priority: 0
]

{ #category : #adding }
SLVMModule >> addGlobal: aGlobalVariable destructor: destructor priority: priority [
	globalDestructors add: (SLVMGlobalConstructorDestructorMetadata new
		global: aGlobalVariable;
		function: destructor;
		priority: priority;
		yourself)
]

{ #category : #adding }
SLVMModule >> addHighLevelEntity: highLevelEntity mapToGlobalValue: globalValue [
	globalValue name ifNil: [ ^ self ].
	highLevelMapToSymbol at: highLevelEntity put: globalValue name.
	symbolMapToHighLevel at: globalValue name put: highLevelEntity
]

{ #category : #adding }
SLVMModule >> addHighLevelEntity: highLevelEntity mapToStructureType: structureType [
	structureType name ifNil: [ ^ self ].
	highLevelMapToStructureType at: highLevelEntity put: structureType.
	structureTypeNameToHighLevelMap at: structureType put: highLevelEntity.
]

{ #category : #adding }
SLVMModule >> addPackage: modulePackage [
	packages add: modulePackage
]

{ #category : #packages }
SLVMModule >> addPackageElement: element topoSortResult: result topoSortAdded: addedElements [
	(addedElements includes: element) ifTrue: [ ^ self ].
	addedElements add: element.
	
	element dependencies do: [ :dep |
		self addPackageElement: dep topoSortResult: result topoSortAdded: addedElements
	].

	result add: element.
]

{ #category : #adding }
SLVMModule >> addStructure: aStructure [
	self assert: aStructure name isNotNil.
	structureDictionary at: aStructure name ifPresent: [ :existent |
		^ false
	].
 
	structures add: aStructure.
	structureDictionary at: aStructure name ifAbsentPut: aStructure.
	^ true
]

{ #category : #accessing }
SLVMModule >> allGlobalValues [
	^ globalValues
]

{ #category : #accessing }
SLVMModule >> allGlobalValuesDo: aBlock [
	globalValues do: aBlock
]

{ #category : #enumerating }
SLVMModule >> allInstructionsDo: aBlock [
	self allGlobalValuesDo: [ :global |
		global isFunction ifTrue: [
			global allInstructionsDo: aBlock
		]
	]
]

{ #category : #optimizations }
SLVMModule >> applyFunctionOptimizationPasses: passes [
	globalValues do: [ :val | val isFunction ifTrue: [ val applyFunctionOptimizationPasses: passes ] ].
]

{ #category : #converting }
SLVMModule >> asFullSExpression [
	^ {
		#structures . structures collect: [:each | each asFullSExpression ] as: Array.
		#globals . globalValues collect: [:each | each asFullSExpression ] as: Array.
		#constructors . globalConstructors collect: [:each | each asFullSExpression ] as: Array.
		#destructors . globalDestructors collect: [:each | each asFullSExpression ] as: Array.
	}
]

{ #category : #converting }
SLVMModule >> asLowLevelModule [
	^ compilationTarget generateLowLevelModule: self
]

{ #category : #converting }
SLVMModule >> asLowLevelModuleWithOptimizationLevel: anOptimizationLevel [
	^ compilationTarget generateLowLevelModule: self optimizationLevel: anOptimizationLevel
]

{ #category : #converting }
SLVMModule >> asPublicInterfaceDeclarationModule [
	| result |
	result := self class new compilationTarget: self compilationTarget.
	structures do: [ :structure |
		result addStructure: structure.
		structureTypeNameToHighLevelMap at: structure ifPresent: [ :highLevelEntity |
			result addHighLevelEntity: highLevelEntity mapToStructureType: structure
		]
	].

	globalValues do: [ :globalValue |
		globalValue createPublicInterfaceDeclarationVersionIn: result.
	].

	^ result
]

{ #category : #converting }
SLVMModule >> asSExpression [
	^ self asFullSExpression
]

{ #category : #accessing }
SLVMModule >> childrenNodes [
	^ globalValues
]

{ #category : #accessing }
SLVMModule >> classVariableClassMap [
	^ classVariableClassMap ifNil: [ classVariableClassMap := IdentityDictionary new ]
]

{ #category : #accessing }
SLVMModule >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMModule >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #optimizations }
SLVMModule >> createFunctionOptimizationPassesForLevel: optimizationLevel [
	| passes |
	passes := OrderedCollection new.
	passes addAll: {
		SLVMOptPromoteAllocas.
		SLVMOptPointerAliasingPass.
		SLVMOptBasicOptimizations.
	}.
	
	"Add lot more passes depending on the optimization level."
	^ passes asArray
]

{ #category : #accessing }
SLVMModule >> debugInformation [
	^ debugInformation
]

{ #category : #accessing }
SLVMModule >> debugInformation: anObject [
	self halt.
	debugInformation := anObject
]

{ #category : #deserialization }
SLVMModule >> decodeConstructorsFrom: encodedConstructors [
	encodedConstructors do: [ :encodedConstructor |
		self halt.
	].
]

{ #category : #deserialization }
SLVMModule >> decodeDestructorsFrom: encodedDestructors [
	encodedDestructors do: [ :encodedDestructor |
		self halt.
	].
]

{ #category : #deserialization }
SLVMModule >> decodeFromFullSExpression: fullSExpression [
	| dict |
	dict := Dictionary newFromPairs: fullSExpression.
	self
		decodeStructuresFrom: (dict at: #structures ifAbsent: [#()]);
		decodeGlobalsFrom: (dict at: #globals ifAbsent: [#()]);
		decodeConstructorsFrom: (dict at: #constructors ifAbsent: [#()]);
		decodeDestructorsFrom: (dict at: #constructors ifAbsent: [#()])
]

{ #category : #deserialization }
SLVMModule >> decodeGlobalsFrom: encodedGlobals [
	globalDecodeBaseIndex := globalValues size.
	"First stage: declare the global values."
	encodedGlobals do: [ :encodedGlobal |
		| mnemonic valueClass globalValue |
		self assert: encodedGlobal isArray.
		mnemonic := encodedGlobal first.
		valueClass := SLVMValue valueClassFromMnemonic: mnemonic.
		self assert: valueClass isNotNil.

		globalValue := valueClass new.
		self assert: (globalValue isNotNil and: [globalValue isGlobalValue]).
		self add: (globalValue decodeDeclarationFromSExpression: encodedGlobal context: self).
	].

	"Second stage: define the global values."
	encodedGlobals doWithIndex: [ :encodedGlobal :index |
		| globalValue |
		globalValue := globalValues at: index + globalDecodeBaseIndex.
		globalValue decodeDefinitionFromSExpression: encodedGlobal context: self
	].


	
]

{ #category : #deserialization }
SLVMModule >> decodeSExpressionType: typeExpression [
	| result mnemonic typeClass |
	typeExpression isSymbol ifTrue: [ 
		"HACK: for the double alignment."
		typeExpression == #f64 ifTrue: [ ^ self compilationTarget double ].
	
		result := SLVMType builtInTypeFromMnemonic: typeExpression.
		self assert: result isNotNil.
		^ result
	].

	self assert: typeExpression isArray.
	mnemonic := typeExpression first.
	typeClass := SLVMType typeClassFromMnemonic: mnemonic.
	self assert: typeClass isNotNil.
	((typeClass includesBehavior: SLVMStructureType) and: [typeExpression size = 2]) ifTrue: [
		^ structureDictionary at: typeExpression second.
	].

	^ typeClass new decodeFromFullSExpression: typeExpression context: self

]

{ #category : #deserialization }
SLVMModule >> decodeSExpressionValue: encodedValue [
	self halt
]

{ #category : #deserialization }
SLVMModule >> decodeStructuresFrom: structuresList [
	"First: declare the structures"
	| baseIndex |
	baseIndex := structures size.
	structuresList do: [ :encodedStructure |
		| structureClass |
		self assert: encodedStructure isArray.
		structureClass := SLVMType typeClassFromMnemonic: encodedStructure first.
		self assert: structureClass isNotNil.
		self addStructure: (structureClass new name: encodedStructure second; yourself)
	].

	"Second: parse the actual structure types."
	structuresList doWithIndex: [ :encodedStructure :index |
		| structure |
		structure := structures at: index + baseIndex.
		structure decodeFromFullSExpression: encodedStructure context: self
	].

	"Ensure the layout is computed."
	baseIndex + 1 to: structures size do: [ :i |
		(structures at: i) computeLayout
	].
]

{ #category : #accessing }
SLVMModule >> disableSLVMOptimizations [
	^ disableSLVMOptimizations ifNil: [ disableSLVMOptimizations := false ]
]

{ #category : #accessing }
SLVMModule >> disableSLVMOptimizations: aBoolean [
	disableSLVMOptimizations := aBoolean
]

{ #category : #printing }
SLVMModule >> fullPrintOn: aStream [
	structures do: [ :struct | struct fullPrintOn: aStream ].
	globalValues do: [ :val | val fullPrintOn: aStream ].
]

{ #category : #printing }
SLVMModule >> fullPrintString [
	^ SLVMPrintingStream fullPrintString: self
]

{ #category : #printing }
SLVMModule >> fullPrintText [
	^ SLVMPrintingTextStream fullPrintString: self
]

{ #category : #building }
SLVMModule >> functionName: name arguments: arguments returnType: returnType [
	| function |
	function := SLVMFunction pointerSize: compilationTarget pointerSize name: name functionType: (SLVMFunctionType arguments: arguments returnType: returnType).
	function compilationTarget: compilationTarget.
	
	self add: function.
	^ function
]

{ #category : #'as yet unclassified' }
SLVMModule >> functionName: name callingConvention: callingConvention arguments: arguments returnType: returnType [
	| function |
	function := SLVMFunction pointerSize: compilationTarget pointerSize name: name functionType: (SLVMFunctionType callingConvention: callingConvention arguments: arguments returnType: returnType).
	function compilationTarget: compilationTarget.
	
	self add: function.
	^ function
]

{ #category : #building }
SLVMModule >> functionName: name fixedArguments: arguments returnType: returnType [
	| function functionType |
	functionType := (SLVMFunctionType arguments: arguments returnType: returnType) variadic: true.
	function := SLVMFunction pointerSize: compilationTarget pointerSize name: name functionType: functionType.
	function compilationTarget: compilationTarget.
	self add: function.
	^ function
]

{ #category : #packages }
SLVMModule >> generatePackageRegistration [
	| registrationFunctionType packageRegistrationFunction allocaBuilder codeBuilder allocaBlock entryBlock |
	registrationFunctionType := SLVMFunctionType arguments: #() returnType: SLVMType voidType.
	packageRegistrationFunction := SLVMFunction pointerSize: compilationTarget pointerSize functionType: registrationFunctionType.
	packageRegistrationFunction
		compilationTarget: compilationTarget;
		makePrivate.
	
	"Generate two basic blocks, one for the locals, and another for the code itself."
	allocaBuilder := SLVMBuilder on: packageRegistrationFunction.
	allocaBlock := allocaBuilder newBasicBlock: #locals.
	allocaBuilder currentBlock: allocaBlock.
	
	codeBuilder := SLVMBuilder on: packageRegistrationFunction.
	entryBlock := codeBuilder newBasicBlock: #entry.
	codeBuilder currentBlock: entryBlock.
	
	"Generate the packages"
	packages do: [ :package |
		package emitFor: self registrationWithAllocaBuilder: allocaBuilder codeBuilder: codeBuilder
	].

	"Generate the package elements, with topological sorting."
	self sortPackageElements do: [ :element |
		element emitFor: self registrationWithAllocaBuilder: allocaBuilder codeBuilder: codeBuilder
	].
	
	"Finish the alloc block, and return."
	allocaBuilder jump: entryBlock.
	codeBuilder returnVoid.
	
	^ packageRegistrationFunction
]

{ #category : #adding }
SLVMModule >> getOrCreateNonInlineLiteralFor: literalValue [
	^ nonInlineLiteralsTable at: literalValue ifAbsentPut: [
		| nonInlineLiteral |
		nonInlineLiteral := SLVMNonInlineLiteral new
			literalValue: literalValue ;
			index: nonInlineLiterals size;
			yourself.
		nonInlineLiterals add: nonInlineLiteral.
		nonInlineLiteral
	]
]

{ #category : #accessing }
SLVMModule >> globalConstructors [
	^ globalConstructors
]

{ #category : #accessing }
SLVMModule >> globalDestructors [
	^ globalDestructors
]

{ #category : #adding }
SLVMModule >> globalNamed: aSymbol [
	^ globalValueDictionary at: aSymbol
]

{ #category : #adding }
SLVMModule >> globalNamed: aSymbol ifAbsent: aBlock [
	^ globalValueDictionary at: aSymbol ifAbsent: aBlock
]

{ #category : #adding }
SLVMModule >> globalNamed: aSymbol ifPresent: aBlock [
	^ globalValueDictionary at: aSymbol ifPresent: aBlock
]

{ #category : #optimizations }
SLVMModule >> globalOptimizeWithLevel: optimizationLevel keepStructuredControlFlow: keepStructuredControlFlow [
	| globalOptimization |
	optimizationLevel = 0 ifTrue: [ ^ self ].
	globalOptimization := SLVMOptInline new.
	globalOptimization keepStructuredControlFlow: keepStructuredControlFlow.
	globalOptimization postInlineOptimizations: (self createFunctionOptimizationPassesForLevel: optimizationLevel).
		
	self applyFunctionOptimizationPasses: {globalOptimization}.
]

{ #category : #accessing }
SLVMModule >> globalValues [
	^ globalValueDictionary
]

{ #category : #'gt inspector extensions' }
SLVMModule >> gtTextViewIn: composite [
	<gtInspectorPresentationOrder: 1>
	composite text
		title: 'Text';
		format: #fullPrintText
]

{ #category : #'gt inspector extensions' }
SLVMModule >> gtTreeViewIn: composite [
	<gtInspectorPresentationOrder: 0>
	composite tree 
		title: 'Nodes';
		display: [ :node | node ];
		children: [ :each | each childrenNodes];
		format: [ :node | node nodeTitle ]
]

{ #category : #accessing }
SLVMModule >> highLevelMapToStructureType [
	^ highLevelMapToStructureType
]

{ #category : #accessing }
SLVMModule >> highLevelMapToSymbol [
	^ highLevelMapToSymbol
]

{ #category : #'as yet unclassified' }
SLVMModule >> importGlobalValue: externalGlobalValue fromModule: importedSSAModule [
	^ externalGlobalValue importIntoModule: self fromModule: importedSSAModule
]

{ #category : #'as yet unclassified' }
SLVMModule >> importType: externalType fromModule: importedSSAModule [
	externalType importIntoModule: self fromModule: importedSSAModule
]

{ #category : #adding }
SLVMModule >> includesGlobalNamed: globalName [
	^ globalValueDictionary includesKey: globalName
]

{ #category : #initialization }
SLVMModule >> initialize [
	structures := OrderedCollection new.
	structureDictionary := Dictionary new.
	globalValues := OrderedCollection new.
	globalValueDictionary := Dictionary new.
	packages := OrderedCollection new.
	inlineAssemblyFragments := OrderedCollection new.
	globalConstructors := OrderedCollection new.
	globalDestructors := OrderedCollection new.
	highLevelMapToStructureType := Dictionary new.
	structureTypeNameToHighLevelMap := Dictionary new.
	highLevelMapToSymbol := Dictionary new.
	symbolMapToHighLevel := Dictionary new.
	nonInlineLiterals := OrderedCollection new.
	nonInlineLiteralsTable := IdentityDictionary new.
	currentOptimizationLevel := 0.
]

{ #category : #accessing }
SLVMModule >> inlineAssemblyFragments [
	^ inlineAssemblyFragments
]

{ #category : #'as yet unclassified' }
SLVMModule >> nodeTitle [
	^ #Module
]

{ #category : #accessing }
SLVMModule >> nonInlineLiterals [
	^ nonInlineLiterals
]

{ #category : #optimizations }
SLVMModule >> optimizeGlobalVariables [
	SLVMOptGlobalVariables passOnModule: self
]

{ #category : #optimizations }
SLVMModule >> optimizeWithLevel: optimizationLevel [
	| functionOptimizationPasses |
	currentOptimizationLevel := optimizationLevel.
	optimizationLevel = 0 ifTrue: [ ^ self ].
	functionOptimizationPasses := self createFunctionOptimizationPassesForLevel: optimizationLevel.
	self applyFunctionOptimizationPasses: functionOptimizationPasses.
]

{ #category : #accessing }
SLVMModule >> packages [
	^ packages
]

{ #category : #types }
SLVMModule >> pointerTypeFor: baseType [
	^ self pointerTypeFor: baseType  storage: SLVMType genericStorage
]

{ #category : #types }
SLVMModule >> pointerTypeFor: baseType storage: storage [
	^ SLVMPointerType size: compilationTarget pointerSize baseType: baseType storage: storage
]

{ #category : #'as yet unclassified' }
SLVMModule >> recomputeGlobalValueIndices [
	globalValues doWithIndex: [ :globalValue :index |
		globalValue globalValueIndex: index - 1
	].
]

{ #category : #'as yet unclassified' }
SLVMModule >> registerClassVariable: classVariable class: classVariableClass [
	self classVariableClassMap at: classVariable put: classVariableClass
]

{ #category : #packages }
SLVMModule >> sortPackageElements [
	| addedElements result |
	addedElements := Set new.
	result := OrderedCollection new.
	
	packages do: [ :package |
		package elements do: [ :element |
			self addPackageElement: element topoSortResult: result topoSortAdded: addedElements
		]
	].
	
	^ result
]

{ #category : #accessing }
SLVMModule >> sourceLanguageName [
	^ sourceLanguageName
]

{ #category : #accessing }
SLVMModule >> sourceLanguageName: anObject [
	sourceLanguageName := anObject
]

{ #category : #accessing }
SLVMModule >> structureNamed: structureName [
	^ structureDictionary at: structureName
]

{ #category : #accessing }
SLVMModule >> structures [
	^ structures
]

{ #category : #accessing }
SLVMModule >> symbolMapToHighLevel [
	^ symbolMapToHighLevel
]

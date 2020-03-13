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
		'globalValues'
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
	structures add: aStructure
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
		result addStructure: structure
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
	globalValueDictionary values do: [ :val | val fullPrintOn: aStream ].

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
SLVMModule >> highLevelMapToSymbol [
	^ highLevelMapToSymbol
]

{ #category : #adding }
SLVMModule >> includesGlobalNamed: globalName [
	^ globalValueDictionary includesKey: globalName
]

{ #category : #initialization }
SLVMModule >> initialize [
	structures := OrderedCollection new.
	globalValues := OrderedCollection new.
	globalValueDictionary := OrderedDictionary new.
	packages := OrderedCollection new.
	inlineAssemblyFragments := OrderedCollection new.
	globalConstructors := OrderedCollection new.
	globalDestructors := OrderedCollection new.
	highLevelMapToSymbol := Dictionary new.
	symbolMapToHighLevel := Dictionary new.
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
SLVMModule >> structures [
	^ structures
]

{ #category : #accessing }
SLVMModule >> symbolMapToHighLevel [
	^ symbolMapToHighLevel
]

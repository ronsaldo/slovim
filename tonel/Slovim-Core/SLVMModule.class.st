Class {
	#name : #SLVMModule,
	#superclass : #SLVMObject,
	#instVars : [
		'compilationTarget',
		'globalValues',
		'anonymousGlobals',
		'packages',
		'classVariableClassMap',
		'debugInformation'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #adding }
SLVMModule >> add: aGlobalValue [
	aGlobalValue module: self.
	aGlobalValue name ifNil: [ ^ anonymousGlobals add: aGlobalValue ].
	globalValues at: aGlobalValue name put: aGlobalValue
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

{ #category : #accessing }
SLVMModule >> allGlobalValues [
	^ globalValues values , anonymousGlobals
]

{ #category : #optimizations }
SLVMModule >> applyFunctionOptimizationPasses: passes [
	globalValues valuesDo: [ :val | val isFunction ifTrue: [ val applyFunctionOptimizationPasses: passes ] ].
	anonymousGlobals do: [ :val | val isFunction ifTrue: [ val applyFunctionOptimizationPasses: passes ] ].
]

{ #category : #converting }
SLVMModule >> asLowLevelModule [
	^ compilationTarget generateLowLevelModule: self
]

{ #category : #accessing }
SLVMModule >> childrenNodes [
	^ anonymousGlobals , globalValues values
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
	debugInformation := anObject
]

{ #category : #printing }
SLVMModule >> fullPrintOn: aStream [
	anonymousGlobals do: [ :val | val fullPrintOn: aStream ].
	globalValues values do: [ :val | val fullPrintOn: aStream ].

]

{ #category : #printing }
SLVMModule >> fullPrintString [
	"Answer a String whose characters are a description of the receiver."

	^ String streamContents: [:s | self fullPrintOn: s]
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
SLVMModule >> globalNamed: aSymbol [
	^ globalValues at: aSymbol
]

{ #category : #adding }
SLVMModule >> globalNamed: aSymbol ifPresent: aBlock [
	^ globalValues at: aSymbol ifPresent: aBlock
]

{ #category : #accessing }
SLVMModule >> globalValues [
	^ globalValues
]

{ #category : #'gt inspector extensions' }
SLVMModule >> gtTextViewIn: composite [
	<gtInspectorPresentationOrder: 1>
	composite text
		title: 'Text';
		display: [ :node | node fullPrintString ]
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

{ #category : #initialization }
SLVMModule >> initialize [
	anonymousGlobals := OrderedCollection new.
	globalValues := OrderedDictionary new.
	packages := OrderedCollection new.
]

{ #category : #'as yet unclassified' }
SLVMModule >> nodeTitle [
	^ #Module
]

{ #category : #optimizations }
SLVMModule >> optimizeWithLevel: optimizationLevel [
	| functionOptimizationPasses |
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

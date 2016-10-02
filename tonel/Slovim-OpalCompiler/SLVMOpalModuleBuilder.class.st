Class {
	#name : #SLVMOpalModuleBuilder,
	#superclass : #Object,
	#instVars : [
		'module',
		'convertedMethods',
		'convertedClasses'
	],
	#category : #'Slovim-OpalCompiler-Package'
}

{ #category : #adding }
SLVMOpalModuleBuilder >> addClass: aClass modulePackage: modulePackage [
	| element |
	convertedClasses at: aClass ifPresent: [ :oldElement | ^ oldElement ].
	
	element := SLVMModulePackageClass new
		name: aClass name;
		actualClass: aClass;
		yourself.
	modulePackage addElement: element.
	convertedClasses at: aClass put: element.
]

{ #category : #adding }
SLVMOpalModuleBuilder >> addMethod: aCompiledMethod modulePackage: modulePackage [
	| compiler crossCompiled methodClass packageElement |
	convertedMethods at: aCompiledMethod ifPresent: [ :existingMethod | ^ existingMethod ].

	compiler := aCompiledMethod methodClass compiler.
	compiler compilationContext: (compiler compilationContext as: SLVMOpalCompilationContext).
	compiler compilationContext
		compilationTarget: module compilationTarget;
		astTranslatorClass: SLVMOpalASTTranslator.
		
	crossCompiled := compiler source: aCompiledMethod sourceCode; compile.
	crossCompiled
		needsCompiledMethodObject: true;
		makePrivate.
		
	(aCompiledMethod pragmaAt: #csymbol:) ifNotNil: [ :pragma |
		crossCompiled name: pragma arguments first asSymbol
	].
	(aCompiledMethod pragmaAt: #cvisibility:) ifNotNil: [ :pragma |
		crossCompiled visibility: pragma arguments first asSymbol
	].
	 
	module add: crossCompiled.
	convertedMethods at: aCompiledMethod put: crossCompiled.

	methodClass := aCompiledMethod methodClass.
	packageElement := SLVMModulePackageMethod new
			name: aCompiledMethod selector;
			compiledValue: crossCompiled;
			className: methodClass baseClass name;
			classSide: methodClass isMeta;
			yourself.

	modulePackage addElement: packageElement.
	convertedClasses at: methodClass ifPresent: [ :classElement |
		packageElement addDependency: classElement
	].

]

{ #category : #adding }
SLVMOpalModuleBuilder >> addMethods: methods modulePackage: modulePackage [
	methods do: [ :method | self addMethod: method modulePackage: modulePackage ]
]

{ #category : #private }
SLVMOpalModuleBuilder >> addMissingSuperclassDependencies [
	convertedClasses valuesDo: [ :class |
		convertedClasses at: class actualClass superclass ifPresent: [ :existingSuper |
			class addDependency: existingSuper
		]
	]
]

{ #category : #adding }
SLVMOpalModuleBuilder >> addPackage: aPackage [
	| modulePackage |
	modulePackage := SLVMModulePackage new name: aPackage name.
	module addPackage: modulePackage.
	
	aPackage definedClasses do: [ :class |
		self addClass: class modulePackage: modulePackage.
		self addMethods: (aPackage definedMethodsForClass: class) modulePackage: modulePackage.
	].

	self addMethods: aPackage extensionMethods modulePackage: modulePackage.
	self addMissingSuperclassDependencies.

]

{ #category : #adding }
SLVMOpalModuleBuilder >> addPackageNamed: aPackageName [
	self addPackage: (RPackage organizer packageNamed: aPackageName)
]

{ #category : #accessing }
SLVMOpalModuleBuilder >> compilationTarget [
	^ module compilationTarget
]

{ #category : #accessing }
SLVMOpalModuleBuilder >> compilationTarget: aCompilationTarget [
	module compilationTarget: aCompilationTarget
]

{ #category : #initialization }
SLVMOpalModuleBuilder >> initialize [
	super initialize.
	module := SLVMModule new.
	convertedClasses := IdentityDictionary new.
	convertedMethods := IdentityDictionary new.

]

{ #category : #accessing }
SLVMOpalModuleBuilder >> module [
	^ module
]

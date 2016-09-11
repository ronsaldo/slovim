Class {
	#name : #SLVMOpalModuleBuilder,
	#superclass : #Object,
	#instVars : [
		'module',
		'convertedMethods'
	],
	#category : #'Slovim-OpalCompiler-Package'
}

{ #category : #adding }
SLVMOpalModuleBuilder >> addClass: aClass [
]

{ #category : #adding }
SLVMOpalModuleBuilder >> addMethod: aCompiledMethod [
	| compiler crossCompiled |
	convertedMethods at: aCompiledMethod ifPresent: [ :existingMethod | ^ existingMethod ].

	compiler := aCompiledMethod methodClass compiler.
	compiler compilationContext: (compiler compilationContext as: SLVMOpalCompilationContext).
	compiler compilationContext
		compilationTarget: module compilationTarget;
		astTranslatorClass: SLVMOpalASTTranslator.
		
	crossCompiled := compiler source: aCompiledMethod sourceCode; compile.
	crossCompiled makePrivate.
	(aCompiledMethod pragmaAt: #csymbol:) ifNotNil: [ :pragma |
		crossCompiled name: pragma arguments first asSymbol
	].
	(aCompiledMethod pragmaAt: #cvisibility:) ifNotNil: [ :pragma |
		crossCompiled visibility: pragma arguments first asSymbol
	].
	 
	module add: crossCompiled.
	convertedMethods at: aCompiledMethod put: crossCompiled.

]

{ #category : #adding }
SLVMOpalModuleBuilder >> addMethods: methods [
	methods do: [ :method | self addMethod: method ]
]

{ #category : #adding }
SLVMOpalModuleBuilder >> addPackage: aPackage [
	aPackage definedClasses do: [ :class |
		self addClass: class.
		self addMethods: (aPackage definedMethodsForClass: class)
	].
	
	self addMethods: aPackage extensionMethods

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
	convertedMethods := IdentityDictionary new.
]

{ #category : #accessing }
SLVMOpalModuleBuilder >> module [
	^ module
]

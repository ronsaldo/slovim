Class {
	#name : #SLVMLirCodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'functionCodeGeneratorClass',
		'compilationTarget',
		'translatedElements',
		'lirModule',
		'objectSectionData'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #adding }
SLVMLirCodeGenerator >> addDynamicObject: dynamicObject [
	| objectSerializer |
	objectSerializer := self objectSerializer.
	^ SLVMLirLabelValue new label: objectSerializer;
			size: compilationTarget pointerSize;
			labelOffset:  (objectSerializer addObject: dynamicObject);
			yourself
]

{ #category : #accessing }
SLVMLirCodeGenerator >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMLirCodeGenerator >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #initialization }
SLVMLirCodeGenerator >> initialize [
	super initialize.
	compilationTarget := SLVM32BitsPointerCompilationTarget new.
	functionCodeGeneratorClass := SLVMLirFunctionCodeGenerator.
]

{ #category : #'code generation' }
SLVMLirCodeGenerator >> isInliningMandatory [
	^ false
]

{ #category : #testing }
SLVMLirCodeGenerator >> needSSADestroyed [
	^ true
]

{ #category : #'code generation' }
SLVMLirCodeGenerator >> needStructuredControlFlow [
	^ false
]

{ #category : #'as yet unclassified' }
SLVMLirCodeGenerator >> objectSerializer [
	objectSectionData ifNotNil: [ ^ objectSectionData ].

	objectSectionData := SLVMLirObjectSerializer new pointerSize: compilationTarget pointerSize.
	lirModule objectSectionData: objectSectionData.
	^ objectSectionData
]

{ #category : #'as yet unclassified' }
SLVMLirCodeGenerator >> runtimeProvidedFunction: symbol [
	| result |
	translatedElements at: symbol ifPresent: [ :incomplete | ^ incomplete ].
	result := SLVMLirFunction new
		compilationTarget: compilationTarget;
		name: symbol;
		visibility: #public;
		yourself.
	translatedElements at: symbol put: result.
	lirModule addElement: result.
	^ result
]

{ #category : #'as yet unclassified' }
SLVMLirCodeGenerator >> runtimeProvidedGlobal: symbol [
	self flag: 'Implement myself properly.'.
	^ self runtimeProvidedFunction: symbol
]

{ #category : #'code generation' }
SLVMLirCodeGenerator >> translateModule: module [
	| packageRegistration |
	module packages ifNotEmpty: [
		packageRegistration := module generatePackageRegistration.
	].

	^ self translateModule: module exportList: module allGlobalValues packageRegistration: packageRegistration
]

{ #category : #'code generation' }
SLVMLirCodeGenerator >> translateModule: module exportList: exportList [
	^ self translateModule: module exportList: exportList packageRegistration: nil
]

{ #category : #'code generation' }
SLVMLirCodeGenerator >> translateModule: module exportList: exportList packageRegistration: packageRegistration [
	self applyPassesIn: module functionList: exportList.
	lirModule := SLVMLirModule new compilationTarget: compilationTarget.
	translatedElements := Dictionary new.

	exportList do: [ :element |
		self translateModuleElement: element
	].

	packageRegistration ifNotNil: [
		lirModule packageRegistration: (self translateModuleElement: packageRegistration)
	].

	^ lirModule

	
]

{ #category : #'as yet unclassified' }
SLVMLirCodeGenerator >> translateModuleElement: element [
	 ^ element accept: self
	
]

{ #category : #visiting }
SLVMLirCodeGenerator >> visitFunction: aFunction [
	| functionCodeGenerator result |
	translatedElements at: aFunction ifPresent: [ :incomplete | ^ incomplete ].
	result := SLVMLirFunction new
		compilationTarget: compilationTarget;
		name: aFunction name;
		visibility: aFunction visibility;
		yourself.
	translatedElements at: aFunction put: result.
	lirModule addElement: result.
	
	functionCodeGenerator := functionCodeGeneratorClass new.
	functionCodeGenerator
		compilationTarget: compilationTarget;
		moduleTranslator: self;
		generateFunction: aFunction into: result.
	^ result
]

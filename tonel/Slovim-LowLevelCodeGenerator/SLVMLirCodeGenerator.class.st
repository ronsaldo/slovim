Class {
	#name : #SLVMLirCodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'functionCodeGeneratorClass',
		'compilationTarget',
		'translatedElements',
		'lirModule'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

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

{ #category : #'code generation' }
SLVMLirCodeGenerator >> needStructuredControlFlow [
	^ false
]

{ #category : #'code generation' }
SLVMLirCodeGenerator >> translateModule: module exportList: exportList [
	self applyOptimizationsIn: module functionList: exportList.
	lirModule := SLVMLirModule new compilationTarget: compilationTarget.
	translatedElements := Dictionary new.
	exportList do: [ :element |
		self translateModuleElement: element
	].

	^ lirModule

	
]

{ #category : #'as yet unclassified' }
SLVMLirCodeGenerator >> translateModuleElement: element [
	 ^ element accept: self
	
]

{ #category : #'as yet unclassified' }
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
	functionCodeGenerator generateFunction: aFunction into: result.
	^ result
]

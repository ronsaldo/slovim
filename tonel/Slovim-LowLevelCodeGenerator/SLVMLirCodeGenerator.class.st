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

{ #category : #'as yet unclassified' }
SLVMLirCodeGenerator >> addDynamicObject: dynamicObject [
	| objectSerializer |
	objectSerializer := self objectSerializer.
	^ SLVMLirLabelValue new label: objectSerializer;
			size: compilationTarget pointerSize;
			labelOffset:  (objectSerializer addObject: dynamicObject);
			yourself
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
	functionCodeGenerator moduleTranslator: self.
	functionCodeGenerator generateFunction: aFunction into: result.
	^ result
]

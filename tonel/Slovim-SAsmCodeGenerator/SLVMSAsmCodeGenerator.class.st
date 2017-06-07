Class {
	#name : #SLVMSAsmCodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'target',
		'classVariableClassMap',
		'sasmModule',
		'translatedElements',
		'runtimeProvidedFunctionst'
	],
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> convertVisibility: visibility [
	^ visibility
]

{ #category : #visiting }
SLVMSAsmCodeGenerator >> createFunctionContextMetaData: function [
	| metadataConstant sasmFunction type metadataVariable |
	sasmFunction := translatedElements at: function.
	sasmFunction contextMetaData ifNotNil: [ ^ self ].
	
	metadataConstant := target objectModel createFunctionContextMetaData: function.
	
	type := metadataConstant type.
	metadataVariable := SAsmGlobalVariable new
		name: (sasmFunction validName , '_cmeta') asSymbol;
		target: sasmModule target;
		visibility: sasmFunction visibility;
		size: type size;
		alignment: type alignment;
		yourself.
	sasmFunction contextMetaData: metadataVariable.
	sasmModule addElement: metadataVariable.
	
	metadataVariable content: SAsmStream new.
	self translateConstant: metadataConstant into: metadataVariable content.

]

{ #category : #visiting }
SLVMSAsmCodeGenerator >> createFunctionContextMetaDataIfNeeded: function [
	| convention |
	convention := sasmModule target callingConventionNamed: function callingConvention.
	(convention hasContextMetadata or: [ function dynamicLiterals isNotEmpty ]) ifFalse: [ ^ self ].

	self createFunctionContextMetaData: function
]

{ #category : #initialization }
SLVMSAsmCodeGenerator >> initialize [
	super initialize.
	runtimeProvidedFunctionst := Dictionary new.
]

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> isInliningMandatory [
	^ false
]

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> needSSADestroyed [
	^ true
]

{ #category : #'runtime functions' }
SLVMSAsmCodeGenerator >> runtimeProvidedFunction: aFunctionOrASymbol [
	aFunctionOrASymbol isSymbol ifTrue: [
		^ runtimeProvidedFunctionst at: aFunctionOrASymbol ifAbsentPut: [SAsmSymbol new name: aFunctionOrASymbol; makeExternal; yourself]
	].
	
	^ self translateModuleElement: aFunctionOrASymbol
]

{ #category : #accessing }
SLVMSAsmCodeGenerator >> target [
	^ target
]

{ #category : #accessing }
SLVMSAsmCodeGenerator >> target: anObject [
	target := anObject
]

{ #category : #visiting }
SLVMSAsmCodeGenerator >> translateConstant: constant into: asmStream [
	| translator value |
	translator := SLVMSAsmConstantDataGenerator new
			target: target;
			sasmTarget: sasmModule target;
			moduleElement: asmStream;
			moduleTranslator: self;
			yourself.
	value := translator translate: constant.
	asmStream addFirst: value asSAsmStreamElement
]

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> translateModule: module [
	| packageRegistration |
	module packages ifNotEmpty: [
		packageRegistration := module generatePackageRegistration.
	].

	^ self translateModule: module exportList: module allGlobalValues packageRegistration: packageRegistration
]

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> translateModule: module exportList: exportList [
	^ self translateModule: module exportList: exportList packageRegistration: nil
]

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> translateModule: module exportList: exportList packageRegistration: packageRegistration [
	classVariableClassMap := module classVariableClassMap.
	self applyPassesIn: module functionList: (exportList select: #isFunction).
	sasmModule := SAsmModule new target: target target.
	translatedElements := Dictionary new.

	exportList do: [ :element |
		self translateModuleElement: element
	].

	packageRegistration ifNotNil: [
		sasmModule packageRegistration: (self translateModuleElement: packageRegistration)
	].

	^ sasmModule
]

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> translateModuleElement: element [
	^ element accept: self
]

{ #category : #visiting }
SLVMSAsmCodeGenerator >> visitFunction: aFunction [
	| functionCodeGenerator result |
	translatedElements at: aFunction ifPresent: [ :incomplete | ^ incomplete ].
	
	result := SAsmFunction new
		name: aFunction name;
		target: sasmModule target;
		visibility: (self convertVisibility: aFunction visibility);
		yourself.
	translatedElements at: aFunction put: result.
	sasmModule addElement: result.
	self createFunctionContextMetaDataIfNeeded: aFunction.

	functionCodeGenerator := SLVMSAsmFunctionCodeGenerator new.
	functionCodeGenerator
		target: target;
		moduleTranslator: self;
		generateFunction: aFunction into: result.
		
	^ result
		
]

{ #category : #visiting }
SLVMSAsmCodeGenerator >> visitGlobalVariable: aGlobalVariable [
	| result type |
	translatedElements at: aGlobalVariable ifPresent: [ :incomplete | ^ incomplete ].
	type := aGlobalVariable valueType.
	
	result := SAsmGlobalVariable new
		name: aGlobalVariable name;
		target: sasmModule target;
		visibility: (self convertVisibility: aGlobalVariable visibility);
		size: type size;
		alignment: type alignment;
		yourself.
	translatedElements at: aGlobalVariable put: result.
	sasmModule addElement: result.
	
	aGlobalVariable initialValue ifNotNil: [
		result content: SAsmStream new.
		self translateConstant: aGlobalVariable initialValue into: result content
	].
	
	^ result
		
]

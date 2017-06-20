Class {
	#name : #SLVMSAsmCodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'target',
		'classVariableClassMap',
		'sasmModule',
		'translatedElements',
		'runtimeProvidedFunctionst',
		'debugCompileUnit',
		'translatedDebugElements',
		'debugTranslator'
	],
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #'debug information' }
SLVMSAsmCodeGenerator >> buildDebugInformation: aBlock [
	debugCompileUnit ifNotNil: [ debugCompileUnit compilationUnit build: aBlock ]
]

{ #category : #'debug information' }
SLVMSAsmCodeGenerator >> buildFunctionDebugInformation: aFunction [
	| translatedFunction functionType |
	aFunction name ifNil: [ ^ self ].
	(aFunction hasProperty: #omitDebugInformation) ifTrue: [ ^ self ].
	
	self buildDebugInformation: [ :builder |
		builder subprogram: [ :subprogram |
			(aFunction isPublic or: [ aFunction isExternal ]) ifTrue: [ subprogram external: true ].
			(aFunction isExternal and: [aFunction isEmpty ]) ifTrue: [ subprogram declaration: true ].
			subprogram prototyped: true.
			
			(aFunction unmangledName isNotNil and: [aFunction unmangledName ~= aFunction name]) ifTrue: [
				subprogram
					"linkageName: aFunction name;"
					name: aFunction unmangledName
			] ifFalse: [
				subprogram name: aFunction name
			].
		
			aFunction isEmpty ifFalse: [
				translatedFunction := translatedElements at: aFunction.
				subprogram lowPC: translatedFunction.
				subprogram highPCOffset: (translatedFunction codeSizeExpression)
			].
		
			functionType := aFunction functionType.
			functionType returnType isVoidType ifFalse: [ 
				subprogram type: (self translateDebugType: functionType returnType)
			]
		].

	].

]

{ #category : #'debug information' }
SLVMSAsmCodeGenerator >> buildGlobalVariableDebugInformation: aGlobalVariable [
	aGlobalVariable name ifNil: [ ^ self ].
	(aGlobalVariable hasProperty: #omitDebugInformation) ifTrue: [ ^ self ].

	self buildDebugInformation: [ :builder |
		builder variable: [ :debugVariable |
			(aGlobalVariable isPublic or: [ aGlobalVariable isExternal ]) ifTrue: [ debugVariable external: true ].
			
			(aGlobalVariable unmangledName isNotNil and: [aGlobalVariable unmangledName ~= aGlobalVariable name]) ifTrue: [
				debugVariable name: aGlobalVariable unmangledName.
				"debugVariable linkageName: aGlobalVariable name."
			] ifFalse: [
				debugVariable name: aGlobalVariable name
			].
		
			debugVariable
				type: (self translateDebugType: aGlobalVariable valueType).

			(aGlobalVariable isExternal and: [aGlobalVariable initialValue isNil]) ifTrue: [
				debugVariable declaration: true
			] ifFalse: [
				debugVariable location build: [ :exprBuilder |
					exprBuilder addr: (translatedElements at: aGlobalVariable)
				]
			]
		]
	]

]

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

{ #category : #'debug information' }
SLVMSAsmCodeGenerator >> debugTranslator [
	^ debugTranslator ifNil: [ debugTranslator := SLVMSAsmDebugTranslator new codeGenerator: self ]
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

{ #category : #accessing }
SLVMSAsmCodeGenerator >> objectModel [
	^ target objectModel
]

{ #category : #'debug information' }
SLVMSAsmCodeGenerator >> register: value debugElement: debugElement [
	translatedDebugElements at: value put: debugElement
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

{ #category : #'debug information' }
SLVMSAsmCodeGenerator >> translateDebugType: aType [
	translatedDebugElements at: aType ifAbsent: [ self debugTranslator translate: aType. ].
	^ translatedDebugElements at: aType
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
	translatedDebugElements := Dictionary new.
	
	self translateModuleDebugInformation: module.

	exportList do: [ :element |
		self translateModuleElement: element
	].

	packageRegistration ifNotNil: [
		sasmModule packageRegistration: (self translateModuleElement: packageRegistration)
	].

	debugCompileUnit ifNotNil: [ debugCompileUnit compilationUnit highPC: sasmModule createDummyFunction ].
	^ sasmModule
]

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> translateModuleDebugInformation: module [
	| debugInfo |
	target emittingDebugInformation ifFalse: [ ^ self ].
	
	debugCompileUnit := sasmModule buildDWCompileUnit: [ :cu |
		debugInfo := module debugInformation.
		debugInfo ifNotNil: [
		].
	
		cu lowPC: sasmModule createDummyFunction
	]
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
		
	self buildFunctionDebugInformation: aFunction.

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

	self buildGlobalVariableDebugInformation: aGlobalVariable.
	
	^ result
		
]

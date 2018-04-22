Class {
	#name : #SLVMLLVMCodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'target',
		'llvmModule',
		'llvmContext',
		'translatedModuleElements',
		'translatedTypes',
		'usedNames',
		'translatedConstants'
	],
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> context [
	^ llvmContext ifNil: [ llvmContext := LLVMContext new ]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> convertLinkage: element [
	self flag: 'TODO: Implement myself'.
	^ LLVMGlobalValue externalLinkage
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> convertName: aName [
	^ aName ifNotNil: [
		aName isLLVMAnon ifTrue: [ nil
		] ifFalse: [
			(usedNames includes: aName) ifTrue: [ nil
			] ifFalse: [
				usedNames add: aName.
				aName
			]
		]
	]
]

{ #category : #initialization }
SLVMLLVMCodeGenerator >> initialize [
	super initialize.
	translatedModuleElements := IdentityDictionary new.
	translatedTypes := IdentityDictionary new.
	translatedConstants := IdentityDictionary new.
	usedNames := Set new.
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> llvmModule [
	^ llvmModule ifNil: [ llvmModule := LLVMModule name: #module context: self context ]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> newFunctionCodeGenerator [
	^ SLVMLLVMFunctionCodeGenerator new
		target: target;
		moduleTranslator: self;
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> recursiveType: type translationDo: aBlock [
	| incomplete result |
	incomplete := LLVMIncompleteType new.
	translatedTypes at: type put: incomplete.
	
	result := aBlock value.
	incomplete becomeForward: result.
	^ result
]

{ #category : #accessing }
SLVMLLVMCodeGenerator >> target [
	^ target
]

{ #category : #accessing }
SLVMLLVMCodeGenerator >> target: anObject [
	target := anObject
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateConstant: aConstant [
	^ translatedConstants at: aConstant ifAbsentPut: [ aConstant accept: self ]
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateModule: module exportList: exportList [
	exportList do: [ :value |
		self translateModuleElement: value
	].
	^ self llvmModule
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateModuleElement: value [
	translatedModuleElements at: value ifPresent: [ :existent | ^ existent ].
	^ value accept: self
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> translateType: aType [
	translatedTypes at: aType ifPresent: [ :existent | ^ existent ].
	^ aType accept: self
]

{ #category : #'code generation' }
SLVMLLVMCodeGenerator >> translateValue: aValue [
	aValue isGlobalValue ifTrue: [ ^ self translateModuleElement: aValue ].
	aValue isConstant ifTrue: [ ^ self translateConstant: aValue ].
	self error: 'Cannot translate value ', aValue printString
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> type: type translationDo: aBlock [
	| result |
	result := aBlock value.
	translatedTypes at: type put: result.
	^ result
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitArrayType: type [
	^ self type: type translationDo: [ 
		LLVMArrayType get: (self translateType: type baseType) elements: type elements
	]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitBoolType: type [
	^ self type: type translationDo: [ self context int1Ty ]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantArrayBlob: constant [
	| type |
	type := self translateType: (constant type addCount: constant hasExtraNullCharacter asBit).
	^ LLVMConstantDataArray new type: type;
		elements: constant data;
		addNull: constant hasExtraNullCharacter ;
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantPointer: constant [
	| type variable pointedValue indexType |
	type := self translateType: constant type.
	pointedValue := self translateConstant: constant constant.
	
	variable := LLVMGlobalVariable createWithType: pointedValue type module: self llvmModule isConstant: true linkage: LLVMGlobalValue privateLinkage.
	variable initialValue: pointedValue.
	
	indexType := type context int32Ty.
	^ LLVMGetElementPtrConstantExpr new
		type: type;
		pointer: variable;
		inbounds: true;
		indices: { indexType zeroConstant . indexType zeroConstant };
		yourself
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitConstantValue: aConstantValue [
	| type |
	type := self translateType: aConstantValue type.
	aConstantValue type isBooleanType ifTrue: [ ^ LLVMConstantInt new type: type; value: aConstantValue asBit ].
	type isIntegerTy ifTrue: [ ^ LLVMConstantInt new type: type; value: aConstantValue value ].
	type isFloatingPointTy ifTrue: [ ^ LLVMConstantFP new type: type; value: aConstantValue value ].
	self error: 'Unsupported constant value type'
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitFunction: aFunction [
	| functionType function |
	functionType := self translateType: aFunction functionType.
	function := LLVMFunction createWithType: functionType linkage: (self convertLinkage: aFunction) name: (self convertName: aFunction name) module: self llvmModule.
	translatedModuleElements at: aFunction put: function.
	
	aFunction isEmpty ifFalse: [ 
		self newFunctionCodeGenerator generateFunction: aFunction into: function
	].
	
	^ function
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitFunctionType: functionType [
	| returnType arguments |
	^ self recursiveType: functionType translationDo: [ 
		returnType := self translateType: functionType returnType.
		arguments := functionType arguments collect: [ :arg | self translateType: arg ].
		LLVMFunctionType get: returnType params: arguments isVarArg: functionType variadic
	]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitIntegerType: type [
	^ self type: type translationDo: [ 
		LLVMIntegerType get: self context bits: type size * 8
	]
]

{ #category : #visiting }
SLVMLLVMCodeGenerator >> visitPointerType: type [
	^ self recursiveType: type translationDo: [
		LLVMPointerType getUnqual: (self translateType: type baseType)
	]
]

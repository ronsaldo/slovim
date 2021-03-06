"
I represent a closure inside a function. I can be instantiated into a normal function that receives the captured state in a structure pointer passed as the first parameter.
"
Class {
	#name : #SLVMClosureDefinition,
	#superclass : #SLVMFunction,
	#instVars : [
		'addressSpace',
		'captures',
		'closureType',
		'normalFunctionTypes',
		'kind',
		'sortedCaptures'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMClosureDefinition class >> mnemonic [
	^ #closure
]

{ #category : #construction }
SLVMClosureDefinition class >> module: module functionType: functionType [
	^ self module: module functionType: functionType addressSpace: SLVMType genericStorage
]

{ #category : #construction }
SLVMClosureDefinition class >> module: module functionType: functionType addressSpace: addressSpace [
	| closureDefinition |
	closureDefinition := self pointerSize: module compilationTarget pointerSize functionType: functionType.
	closureDefinition
		module: module;
		compilationTarget: module compilationTarget;
		addressSpace: addressSpace.
	^ closureDefinition
]

{ #category : #visiting }
SLVMClosureDefinition >> accept: aVisitor [
	^ aVisitor visitClosureDefinition: self
]

{ #category : #accessing }
SLVMClosureDefinition >> addressSpace [
	^ addressSpace
]

{ #category : #accessing }
SLVMClosureDefinition >> addressSpace: anObject [
	addressSpace := anObject
]

{ #category : #printing }
SLVMClosureDefinition >> asFullSExpression [
	^ { self mnemonic . self globalValueIndex . name . functionType callingConvention . functionType returnType asSExpression .
		self globalValueAttributesAsSExpression.
		#captures . captures collect: [ :each | each asFullSExpression ] as: Array.
		#arguments . arguments collect: [ :each | each asFullSExpression ].
		#variadic . functionType variadic .
		#literals . dynamicLiterals collect: [ :each | each asFullSExpression ] as: Array.
		#blocks . basicBlocks collect: [ :each | each asFullSExpression ] as: Array.
	}
]

{ #category : #converting }
SLVMClosureDefinition >> asNormalFunction [
	| normalFunctionType normalFunction valueMap environmentArg environmentPointer prologueInstructions dynamicCaptureCount dynamicCaptureIndex normalCaptureIndex captureIndex capturePointer captureLoad firstBlock closureStructureType |
	self normalFunctionTypes.

	normalFunctionType := normalFunctionTypes first.
	closureStructureType := normalFunctionTypes third.
	
	normalFunction := SLVMFunction pointerSize: type size functionType: normalFunctionType.
	normalFunction
		makePrivate;
		module: module;
		compilationTarget: compilationTarget;
		gcStrategy: self gcStrategy;
		personalityFunction: self personalityFunction;
		name: name;
		unmangledName: self unmangledName;
		debugInformation: self debugInformation;
		debugType: self debugType;
		debugSourceLocation: self debugSourceLocation.
	
	valueMap := IdentityDictionary new.
	self hasStructReturnPointer ifTrue: [ 
		valueMap at: arguments first put: normalFunction arguments first.
		arguments allButFirst doWithIndex: [ :arg :index |
			valueMap at: arg put: (normalFunction arguments at: index + 2)
		].
	] ifFalse: [
		arguments doWithIndex: [ :arg :index |
			valueMap at: arg put: (normalFunction arguments at: index + 1)
		].
	].

	environmentArg := self hasStructReturnPointer ifTrue: [ normalFunction arguments second ] ifFalse: [ normalFunction arguments first ].
	environmentPointer := SLVMGetElementPointer pointer: environmentArg indices: { SLVMConstant int: 0 . SLVMConstant int: closureStructureType types size - 1 }.
	environmentPointer name: #capturedEnvironmentPointer.

	prologueInstructions := OrderedCollection new.
	prologueInstructions add: environmentPointer.
	
	"Map the captures"	
	dynamicCaptureCount := 0.
	captures do: [ :cap |
		cap type isDynamicObjectPointerType ifTrue: [ 
			dynamicCaptureCount := dynamicCaptureCount + 1
		]
	].

	dynamicCaptureIndex := 0.
	normalCaptureIndex := 0.
	captures do: [ :cap |
		cap type isDynamicObjectPointerType ifTrue: [
			captureIndex := dynamicCaptureIndex.
			dynamicCaptureIndex := dynamicCaptureIndex + 1.
		] ifFalse: [
			captureIndex := dynamicCaptureCount + normalCaptureIndex.
			normalCaptureIndex := normalCaptureIndex + 1.
		].
	
		capturePointer := SLVMGetElementPointer pointer: environmentPointer indices: { SLVMConstant int: 0 . SLVMConstant int: captureIndex }.
		captureLoad := SLVMLoadInstruction variable: capturePointer.
		prologueInstructions
			add: capturePointer;
			add: captureLoad.
		valueMap at: cap put: captureLoad
	].

	"Copy the function contents"
	firstBlock := (self copyContentsInto: normalFunction valueMap: valueMap) first.
	
	"Add the prologue instructions, after the allocas"
	firstBlock addInstructionsAfterAllocas: prologueInstructions.
	^ normalFunction
]

{ #category : #accessing }
SLVMClosureDefinition >> captures [
	^ captures
]

{ #category : #accessing }
SLVMClosureDefinition >> closureType [
	^ closureType ifNil: [closureType := SLVMClosureType functionType: functionType hasStructReturnPointer: self hasStructReturnPointer kind: kind captures: (captures collect: [:each | each type]) addressSpace: addressSpace]
]

{ #category : #initialization }
SLVMClosureDefinition >> createClosureCaptureOfType: aCaptureType [
	| capture |
	capture := SLVMClosureCapture new
		function: self;
		type: aCaptureType;
		index: captures size.
	captures add: capture.
	closureType := nil.
	^ capture
]

{ #category : #'as yet unclassified' }
SLVMClosureDefinition >> decodeDefinitionFromSExpression: encodedGlobal context: context [
	| dict encodedCaptures |
	dict := Dictionary newFromPairs: (encodedGlobal allButFirst: 6).
	encodedCaptures := dict at: #captures.
	self halt.
	super decodeDeclarationFromSExpression: encodedGlobal context: context
]

{ #category : #initialization }
SLVMClosureDefinition >> initialize [
	super initialize.
	captures := OrderedCollection new.
]

{ #category : #testing }
SLVMClosureDefinition >> isClosureDefinition [
	^ true
]

{ #category : #accessing }
SLVMClosureDefinition >> kind [
	^ kind
]

{ #category : #accessing }
SLVMClosureDefinition >> kind: anObject [
	kind := anObject
]

{ #category : #enumerating }
SLVMClosureDefinition >> localValuesDo: aBlock [
	captures do: aBlock.
	super localValuesDo: aBlock
]

{ #category : #converting }
SLVMClosureDefinition >> normalFunctionTypes [
	^ normalFunctionTypes ifNil: [normalFunctionTypes := self closureType normalFunctionTypeWith: compilationTarget]
]

{ #category : #accessing }
SLVMClosureDefinition >> sortedCaptures [
	^ sortedCaptures ifNil: [ 
		| dynamicCaptures normalCaptures |
		dynamicCaptures := OrderedCollection new.
		normalCaptures := OrderedCollection new.
		
		captures do: [ :each |
			each type isDynamicObjectPointerType ifTrue: [
				dynamicCaptures add: each.
			] ifFalse: [ 
				normalCaptures add: each.
			]
		].
	
		sortedCaptures := dynamicCaptures asArray , normalCaptures asArray
	]
]

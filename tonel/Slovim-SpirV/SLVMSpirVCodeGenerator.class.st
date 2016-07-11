Class {
	#name : #SLVMSpirVCodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'translatedValues',
		'builder',
		'basicBlockDictionary',
		'instructionDictionary',
		'currentFunction',
		'interfaceList'
	],
	#classVars : [
		'BinaryOperationMap',
		'BuiltInExtensionInstructionMap',
		'EntryPointTypes',
		'StorageClassMap',
		'UnaryOperationMap'
	],
	#pools : [
		'SpirVConstants'
	],
	#category : #'Slovim-SpirV'
}

{ #category : #name }
SLVMSpirVCodeGenerator class >> codeGeneratorName [
	^ #'spir-v'
]

{ #category : #'class initialization' }
SLVMSpirVCodeGenerator class >> initialize [
	"
	self initialize
	"
	| value |
	super initialize.
	
	(Smalltalk at: #SpirVConstants) initialize.
	
	EntryPointTypes := #(
		vertex
		fragment
		compute
		geometry
		tcontrol
		teval
	).
	
	StorageClassMap := IdentityDictionary newFromPairs: #(
		uniformConstant 0
		input 1
		uniform 2
		output 3
		workgroup 4
		crossWorkgroup 5
		private 6
		function 7
		generic 8
		pushConstant 9
		atomicCounter 10
		image 11
	).
	
	BinaryOperationMap := Dictionary new.
	#(
		add 		SpvOpIAdd
		sub 		SpvOpISub 
		mul 		SpvOpIMul
		div 		SpvOpSDiv
		udiv 		SpvOpUDiv
		rem 		SpvOpSRem
		urem 		SpvOpURem

		bitand 	SpvOpBitwiseAnd
		bitor		SpvOpBitwiseOr
		bitxor 	SpvOpBitwiseXor

		shiftleft 	SpvOpShiftLeftLogical
		shiftright 	SpvOpShiftRightLogical
		ashiftright 	SpvOpShiftRightArithmetic

		ieq SpvOpIEqual
		ine SpvOpINotEqual

		ilt SpvOpSLessThan
		ile SpvOpSLessThanEqual
		igt SpvOpSGreaterThan
		ige SpvOpSGreaterThanEqual

		ult SpvOpULessThan
		ule SpvOpULessThanEqual
		ugt SpvOpUGreaterThan
		uge SpvOpUGreaterThanEqual

		fadd 		SpvOpFAdd
		fsub 		SpvOpFSub
		fmul 		SpvOpFMul
		fdiv 		SpvOpFDiv
		frem 		SpvOpFRem
				
		uflt SpvOpFUnordLessThan
		ufle SpvOpFUnordLessThanEqual
		ufeq SpvOpFUnordEqual
		ufne SpvOpFUnordNotEqual
		ufgt SpvOpFUnordGreaterThan
		ufge SpvOpFUnordGreaterThanEqual

		oflt SpvOpFOrdLessThan
		ofle SpvOpFOrdLessThanEqual
		ofeq SpvOpFOrdEqual
		ofne SpvOpFOrdNotEqual
		ofgt SpvOpFOrdGreaterThan
		ofge SpvOpFOrdGreaterThanEqual
		
		mulMatrixMatrix SpvOpMatrixTimesMatrix
		mulMatrixVector SpvOpMatrixTimesVector
		mulVectorMatrix SpvOpVectorTimesMatrix
	) pairsDo: [ :k :v |
		BinaryOperationMap at: k put: (SpirVConstants bindingOf: v) value
	].

	UnaryOperationMap := Dictionary new.
	#(
		not SpvOpNot
		neg SpvOpSNegate
		fneg SpvOpFNegate
	) pairsDo: [ :k :v |
		UnaryOperationMap at: k put: (SpirVConstants bindingOf: v) value
	].

	BuiltInExtensionInstructionMap := Dictionary new.
	#(
		cross (glsl450 GLSLstd450Cross)
		dot (SpirV SpvOpDot)
		length (glsl450 GLSLstd450Length)
		normalize (glsl450 GLSLstd450Normalize)
		reflect (glsl450 GLSLstd450Reflect)
		refract (glsl450 GLSLstd450Refract)
	
		smoothstep (glsl450 GLSLstd450SmoothStep)
		step (glsl450 GLSLstd450Step)
		
		pow (glsl450 GLSLstd450Pow) 
		atan2 (glsl450 GLSLstd450Atan2) 
		
		asin (glsl450 GLSLstd450Asin) 
		sin (glsl450 GLSLstd450Sin)
		asinh (glsl450 GLSLstd450Asinh)
		sinh (glsl450 GLSLstd450Sinh)
		
		acos (glsl450 GLSLstd450Acos) 
		cos (glsl450 GLSLstd450Cos)
		acosh (glsl450 GLSLstd450Acosh)
		cosh (glsl450 GLSLstd450Cosh)
		
		atan (glsl450 GLSLstd450Atan)
		tan (glsl450 GLSLstd450Tan)
		atanh (glsl450 GLSLstd450Atanh)
		
		exp (glsl450 GLSLstd450Exp)
		exp2 (glsl450 GLSLstd450Exp2)
		log (glsl450 GLSLstd450Log)
		log2 (glsl450 GLSLstd450Log2)
		
		sqrt (glsl450 GLSLstd450Sqrt)
		inverseSqrt (glsl450 GLSLstd450InverseSqrt)
		floor (glsl450 GLSLstd450Floor)
		ceil (glsl450 GLSLstd450Ceil)
		trunc (glsl450 GLSLstd450Trunc)
		round (glsl450 GLSLstd450Round)
		roundEven (glsl450 GLSLstd450RoundEven)
		fract (glsl450 GLSLstd450Fract)
		
		degrees (glsl450 GLSLstd450Degrees)
		radians (glsl450 GLSLstd450Radians)
		fabs (glsl450 GLSLstd450FAbs)
		
		fsign (glsl450 GLSLstd450FSign)
			
		smin (glsl450 GLSLstd450SMin)
		umin (glsl450 GLSLstd450UMin)
		fmin (glsl450 GLSLstd450FMin)

		smax (glsl450 GLSLstd450SMax)
		umax (glsl450 GLSLstd450UMax)
		fmax (glsl450 GLSLstd450FMax)
		
		fmix (glsl450 GLSLstd450FMix)
		
		transpose (SpirV SpvOpTranspose)
	) pairsDo: [ :k :v |
		value := (SpirVConstants bindingOf: v second) value.
		self assert: value isNotNil.
		BuiltInExtensionInstructionMap at: k put: { v first . value }
	].
	
]

{ #category : #'as yet unclassified' }
SLVMSpirVCodeGenerator >> basicBlockLabelId: basicBlock [
	^ basicBlockDictionary at: basicBlock ifAbsentPut: [ builder newId ].
]

{ #category : #'as yet unclassified' }
SLVMSpirVCodeGenerator >> functionTranslation: aFunction do: aBlock [
	| oldFunction |
	^ self valueTranslation: aFunction do: [:id |
		oldFunction := currentFunction.
		currentFunction := aFunction.
		[
		builder functionDo: [ aBlock value: id]
		] ensure: [ currentFunction := aFunction ]
	]
]

{ #category : #'as yet unclassified' }
SLVMSpirVCodeGenerator >> generateLazyInstructionId: aValue [
	^ instructionDictionary at: aValue ifAbsentPut: [ builder newId ].

]

{ #category : #initialization }
SLVMSpirVCodeGenerator >> initialize [
	super initialize.
	translatedValues := Dictionary new.
	basicBlockDictionary := Dictionary new.
	instructionDictionary := Dictionary new.
	interfaceList := OrderedCollection new.
]

{ #category : #'as yet unclassified' }
SLVMSpirVCodeGenerator >> instructionTranslation: aValue do: aBlock [
	| instructionId |
	instructionId := instructionDictionary at: aValue ifAbsentPut: [ builder newId ].
	translatedValues at: aValue put: instructionId.
	aBlock value: instructionId.
	^ instructionId.
]

{ #category : #'as yet unclassified' }
SLVMSpirVCodeGenerator >> isEntryPointFunction: aGlobalValue [
	aGlobalValue isFunction ifFalse: [ ^ false ].
	EntryPointTypes do: [ :point | (aGlobalValue hasProperty: point) ifTrue: [ ^ true ] ].
	^ false.
]

{ #category : #'as yet unclassified' }
SLVMSpirVCodeGenerator >> translateBasicBlock: basicBlock [
	| labelId |
	labelId := self basicBlockLabelId: basicBlock.
	builder addFunctionInstruction: (SpirVInstruction opcode: SpvOpLabel result: labelId).
	basicBlock instructionsDo: [ :ins | ins accept: self ] 
]

{ #category : #'as yet unclassified' }
SLVMSpirVCodeGenerator >> translateModule: ssaModule [
	^ SpirVModuleBuilder build: [ :builderArg |
		builder := builderArg.
		ssaModule globalValues valuesDo: [ :globalValue | (self isEntryPointFunction: globalValue) ifTrue: [ self translateValue: globalValue ] ]
	]
]

{ #category : #'as yet unclassified' }
SLVMSpirVCodeGenerator >> translateValue: aValue [
	^ translatedValues at: aValue ifAbsent: [
		aValue isInstruction ifTrue: [ ^ self generateLazyInstructionId: aValue ].
		aValue accept: self
	]
]

{ #category : #'as yet unclassified' }
SLVMSpirVCodeGenerator >> valueTranslation: aValue do: aBlock [
	| valueId |
	(aValue isType not and: [aValue isInstruction]) ifTrue: [ ^ instructionDictionary at: aValue ifAbsentPut: [ builder newId ]].
	valueId := builder newId.
	translatedValues at: aValue put: valueId.
	aBlock value: valueId.
	^ valueId.
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitAlloca: allocaInstruction [
	| resultType |
	^ self instructionTranslation: allocaInstruction do: [ :id |
		resultType := self translateValue: allocaInstruction type.
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpVariable
			type: resultType
			result: id
			operands: { SpvStorageClassFunction })
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitArrayType: arrayType [
	| baseType length |
	^ self valueTranslation: arrayType do: [ :id |
		baseType := self translateValue: arrayType baseType.
		arrayType isBounded ifTrue: [
			length := self translateValue: (SLVMConstant int: arrayType elements).
			builder addTypeInstruction: (SpirVInstruction
				opcode: SpvOpTypeArray
				result: id
				operands: {baseType . length}
			).
		] ifFalse: [ 
			builder addTypeInstruction: (SpirVInstruction
				opcode: SpvOpTypeRuntimeArray
				result: id
				operands: {baseType}
			).
		].

		builder addAnnotationInstruction: (SpirVInstruction
			opcode: SpvOpDecorate 
			operands: {id . SpvDecorationArrayStride . arrayType baseType size }
		)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitBinaryOperation: binaryOp [
	| opcode resultType left right |
	^ self instructionTranslation: binaryOp do: [ :id |
		opcode := BinaryOperationMap at: binaryOp operation.
		resultType := self translateValue: binaryOp type.
		left := self translateValue: binaryOp left.
		right := self translateValue: binaryOp right.
		builder addFunctionInstruction: (SpirVInstruction
			opcode: opcode
			type: resultType
			result: id
			operands: { left . right }
		)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitBoolType: voidType [
	^ self valueTranslation: voidType do: [ :id |
		builder addTypeInstruction: (SpirVInstruction
			opcode: SpvOpTypeBool
			result: id
		)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitBranch: branchInstruction [
	| condition trueBlock falseBlock mergeBlock continueBlock |
	^ self instructionTranslation: branchInstruction do: [ :id |
		condition := self translateValue: branchInstruction condition.
		trueBlock := self basicBlockLabelId: branchInstruction trueBlock. 
		falseBlock := self basicBlockLabelId: branchInstruction falseBlock. 
		branchInstruction mergeBlock ifNotNil: [
			mergeBlock := self basicBlockLabelId: branchInstruction mergeBlock.
			branchInstruction continueBlock ifNotNil: [
				continueBlock := self basicBlockLabelId: branchInstruction continueBlock.
				builder addFunctionInstruction: (SpirVInstruction
					opcode: SpvOpLoopMerge 
					operands: { mergeBlock . continueBlock . SpvLoopControlNone }
				)
			] ifNil: [
				builder addFunctionInstruction: (SpirVInstruction
					opcode: SpvOpSelectionMerge 
					operands: { mergeBlock . SpvSelectionControlNone }
				)
			]
		].
	
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpBranchConditional
			operands: { condition . trueBlock . falseBlock }
		)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitCall: callInstruction [
	| resultType function arguments functionValue setInstructionPair extensionSet extensionInstruction |
	^ self instructionTranslation: callInstruction do: [ :id |
		functionValue := callInstruction functionValue.
		resultType := self translateValue: callInstruction type.
		arguments := callInstruction arguments collect: [:arg | self translateValue: arg].

		functionValue isConstantBuiltInFunction ifTrue: [
			setInstructionPair := BuiltInExtensionInstructionMap at: functionValue name.
			setInstructionPair first = #SpirV ifTrue: [ 
				builder addFunctionInstruction: (SpirVInstruction
					opcode: setInstructionPair second
					type: resultType
					result: id
					operands: arguments)
			] ifFalse: [ 
				extensionSet := builder perform: (setInstructionPair first , #ExtensionSet) asSymbol. 
				extensionInstruction := setInstructionPair second.
				builder addFunctionInstruction: (SpirVInstruction
					opcode: SpvOpExtInst
					type: resultType
					result: id
					operands: { extensionSet . extensionInstruction } , arguments)
			]
		] ifFalse: [ 
			function := self translateValue: functionValue.
			builder addFunctionInstruction: (SpirVInstruction
				opcode: SpvOpFunctionCall
				type: resultType
				result: id
				operands: { function } , arguments)
		]
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitCombineSamplerWithTexture: combineSampler [
	| sampler texture resultType |
	^ self instructionTranslation: combineSampler do: [ :id |
		sampler := self translateValue: combineSampler sampler.
		texture := self translateValue: combineSampler texture.
		resultType := self translateValue: combineSampler type.
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpSampledImage
			type: resultType
			result: id
			operands: { texture . sampler })
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitConstantValue: constantValue [
	| value type encodedValue |
	^ self valueTranslation: constantValue do: [ :id |
		value := constantValue value.
		type := self translateValue: constantValue type.
		
		constantValue type isBooleanType ifTrue: [
			builder addConstantInstruction: (SpirVInstruction
				opcode: (constantValue value ifTrue: [ SpvOpConstantTrue ] ifFalse: [ SpvOpConstantFalse ])
				type: type
				result: id
			) 
		] ifFalse: [
			constantValue type isFloatType ifTrue: [
				constantValue type size = 4 ifTrue: [
					encodedValue := { value asIEEE32BitWord }.
				] ifFalse: [
					encodedValue := { value at: 1 . value at: 2}.
				]
			] ifFalse: [
				constantValue type size > 4 ifTrue: [
					self assert: type size = 8 .
					encodedValue := { value bitAnd: 16rffffffff . (value bitShift: -32) bitAnd: 16rffffffff }
				] ifFalse: [
					encodedValue := { value bitAnd: 16rffffffff }
				]
			].
	
			builder addConstantInstruction: (SpirVInstruction
				opcode: SpvOpConstant
				type: type
				result: id
				operands: encodedValue)
		]
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitExtractVectorElement: extractElement [
	| resultType vector index |
	^ self instructionTranslation: extractElement do: [ :id |
		resultType := self translateValue: extractElement type.
		vector := self translateValue: extractElement vector.
		extractElement index isConstantValue ifTrue: [
			builder addFunctionInstruction: (SpirVInstruction
				opcode: SpvOpCompositeExtract
				type: resultType
				result: id
				operands: { vector . extractElement index value }
			)
		] ifFalse: [ 
			index := self translateValue: extractElement index.
			builder addFunctionInstruction: (SpirVInstruction
				opcode: SpvOpVectorExtractDynamic
				type: resultType
				result: id
				operands: { vector . index }
			)
		]
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitFloatType: floatType [
	^ self valueTranslation: floatType do: [ :id |
		builder addTypeInstruction: (SpirVInstruction opcode: SpvOpTypeFloat result: id operands: {floatType size})
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitFunction: function [
	| functionType resultType |
	^ self functionTranslation: function do: [ :id |
		functionType := self translateValue: function functionType.
		resultType := self translateValue: function functionType returnType.
		
		builder addFunctionInstruction: (SpirVInstruction 
			opcode: SpvOpFunction
			type: resultType
			result: id
			operands: { SpvFunctionControlNone . functionType }
		).
		
		
		currentFunction arguments do: [ :arg | self translateValue: arg ].
		
		function dominanceTopoSort do: [ :basicBlock | self translateBasicBlock: basicBlock ].
		
		builder addFunctionInstruction: (SpirVInstruction opcode: SpvOpFunctionEnd).
		
		function propertyAt: #vertex ifPresent: [ :dummy |
			builder addEntryPointInstruction: (SpirVInstruction
				opcode: SpvOpEntryPoint
				operands: { SpvExecutionModelVertex . id . } , function name asSpirVStringLiteral , interfaceList
			).
		].
		function propertyAt: #fragment ifPresent: [ :dummy |
			builder addEntryPointInstruction: (SpirVInstruction
				opcode: SpvOpEntryPoint
				operands: { SpvExecutionModelFragment . id . } , function name asSpirVStringLiteral , interfaceList
			).
			
			builder addExecutionModeInstruction: (SpirVInstruction
				opcode: SpvOpExecutionMode
				operands: {id . SpvExecutionModeOriginUpperLeft}
			)
		].
		function propertyAt: #geometry ifPresent: [ :dummy |
			self halt.
		].
		function propertyAt: #tcontrol ifPresent: [ :dummy |
			self halt.
		].
		function propertyAt: #teval ifPresent: [ :dummy |
			self halt.
		].
		function propertyAt: #compute ifPresent: [ :dummy |
			self halt.
		].
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitFunctionArgument: functionArgument [
	| type |
	^ self valueTranslation: functionArgument do: [ :id |
		type := self translateValue: functionArgument type.
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpFunctionParameter
			type: type
			result: id)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitFunctionType: functionType [
	| resultType arguments |
	^ self valueTranslation: functionType do: [ :id |
		resultType := self translateValue: functionType returnType.
		arguments := functionType arguments collect: [:arg | self translateValue: arg ].
		builder addTypeInstruction: (SpirVInstruction
			opcode: SpvOpTypeFunction
			result: id
			operands: {resultType} , arguments)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitGetElementReference: getElementRef [
	| resultType pointer index |
	^ self instructionTranslation: getElementRef do: [ :id |
		pointer := self translateValue: getElementRef reference.
		index := self translateValue: getElementRef index.
		resultType := self translateValue: getElementRef type.
		builder addFunctionInstruction: (SpirVInstruction
			opcode: (getElementRef index isConstant ifTrue: [ SpvOpInBoundsAccessChain  ] ifFalse: [ SpvOpAccessChain ]) 
			type: resultType
			result: id
			operands: { pointer . index })
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitGlobalVariable: globalVariable [
	| type storage |
	^ self valueTranslation: globalVariable do: [ :id |
		type := self translateValue: globalVariable type.
		storage := StorageClassMap at: globalVariable type storage.
		builder addGlobalInstruction: (SpirVInstruction
			opcode: SpvOpVariable
			type: type 
			result: id
			operands: { storage }
		).
		
		builder addDebugInstruction: (SpirVInstruction
			opcode: SpvOpName
			operands: { id } , globalVariable name asSpirVStringLiteral
		).
		
		globalVariable propertyAt: #location ifPresent: [ :location |
			interfaceList add: id.
			location >= 0 ifTrue: [ 
				builder addAnnotationInstruction: (SpirVInstruction
					opcode: SpvOpDecorate
					operands: { id . SpvDecorationLocation . location }
				).
			] ifFalse: [
				builder addAnnotationInstruction: (SpirVInstruction
					opcode: SpvOpDecorate
					operands: { id . SpvDecorationBuiltIn . -1 - location }
				).
			]
		].
	
		globalVariable propertyAt: #binding ifPresent: [ :binding |
			builder addAnnotationInstruction: (SpirVInstruction
				opcode: SpvOpDecorate
				operands: { id . SpvDecorationBinding  . binding }
			).
		].
	
		globalVariable propertyAt: #set ifPresent: [ :bindingSet |
			builder addAnnotationInstruction: (SpirVInstruction
				opcode: SpvOpDecorate
				operands: { id . SpvDecorationDescriptorSet  . bindingSet }
			).
		].
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitIntegerType: integerType [
	^ self valueTranslation: integerType do: [ :id |
		builder addTypeInstruction: (SpirVInstruction opcode: SpvOpTypeInt result: id operands: {integerType size . integerType isSigned asBit})
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitJump: jumpInstruction [
	| destination |
	^ self instructionTranslation: jumpInstruction do: [ :id |
		destination := self basicBlockLabelId: (jumpInstruction destination). 
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpBranch
			operands: { destination }
		)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitLoad: loadInstruction [
	| variable resultType |
	^ self instructionTranslation: loadInstruction do: [ :id |
		variable := self translateValue: loadInstruction variable.
		resultType := self translateValue: loadInstruction type.
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpLoad
			type: resultType
			result: id
			operands: { variable })
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitMakeMatrix: makeMatrixInstruction [
	| resultType arguments |
	^ self instructionTranslation: makeMatrixInstruction do: [ :id |
		resultType := self translateValue: makeMatrixInstruction type.
		arguments := makeMatrixInstruction parameters collect: [ :arg | self translateValue: arg ].
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpCompositeConstruct
			type: resultType
			result: id
			operands: arguments)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitMakeVector: makeVectorInstruction [
	| resultType arguments |
	^ self instructionTranslation: makeVectorInstruction do: [ :id |
		resultType := self translateValue: makeVectorInstruction type.
		arguments := makeVectorInstruction parameters collect: [ :arg | self translateValue: arg ].
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpCompositeConstruct
			type: resultType
			result: id
			operands: arguments)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitMatrixType: matrixType [
	| columnType |
	^ self valueTranslation: matrixType do: [ :id |
		columnType := self translateValue: matrixType columnType.
		builder addTypeInstruction: (SpirVInstruction
			opcode: SpvOpTypeMatrix
			result: id
			operands: { columnType . matrixType columns}
		)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitPhi: phiInstruction [
	| parameters resultType |
	parameters := OrderedCollection new.
	^ self instructionTranslation: phiInstruction do: [ :id |
		resultType := self translateValue: phiInstruction type.
		phiInstruction valuesAndParentsDo: [ :value :incomingBlock |
			parameters add: (self translateValue: value).
			parameters add: (self basicBlockLabelId: incomingBlock)
		].
	
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpPhi
			type: resultType
			result: id
			operands: parameters asArray
		)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitReferenceType: referenceType [
	| baseType storage |
	^ self valueTranslation: referenceType do: [ :id |
		baseType := self translateValue: referenceType baseType.
		storage := StorageClassMap at: referenceType storage.
		builder addTypeInstruction: (SpirVInstruction opcode: SpvOpTypePointer result: id operands: { storage . baseType })
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitReturn: returnInstruction [
	| value |
	^ self instructionTranslation: returnInstruction do: [ :id |
		value := self translateValue: returnInstruction value.
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpReturnValue
			operands: { value })
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitReturnVoid: returnVoidInstruction [
	^ self instructionTranslation: returnVoidInstruction do: [ :id |
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpReturn)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitSampleImplicitLod: sampleImplicitLod [
	| sampledTexture texcoord resultType |
	^ self instructionTranslation: sampleImplicitLod do: [ :id |
		sampledTexture := self translateValue: sampleImplicitLod sampledTexture.
		texcoord := self translateValue: sampleImplicitLod texcoord.
		resultType := self translateValue: sampleImplicitLod type.
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpImageSampleImplicitLod
			type: resultType
			result: id
			operands: { sampledTexture . texcoord })
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitSampledTextureType: sampledTextureType [
	| textureType |
	^ self valueTranslation: sampledTextureType do: [ :id |
		textureType := self translateValue: sampledTextureType texture.
		builder addTypeInstruction: (SpirVInstruction
			opcode: SpvOpTypeSampledImage
			result: id
			operands: { textureType }
		)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitSamplerType: samplerType [
	^ self valueTranslation: samplerType do: [ :id |
		builder addTypeInstruction: (SpirVInstruction
			opcode: SpvOpTypeSampler
			result: id
		)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitShuffleVectors: shuffleVectors [
	| resultType firstVector secondVector |
	^ self instructionTranslation: shuffleVectors do: [ :id |
		firstVector := self translateValue: shuffleVectors firstVector.
		secondVector := self translateValue: shuffleVectors secondVector.
		resultType := self translateValue: shuffleVectors type.
		builder addFunctionInstruction: (SpirVInstruction
				opcode: SpvOpVectorShuffle
				type: resultType
				result: id
				operands: { firstVector . secondVector } , shuffleVectors components
		)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitStore: storeInstruction [
	| value variable |
	^ self instructionTranslation: storeInstruction do: [ :id |
		value := self translateValue: storeInstruction value.
		variable := self translateValue: storeInstruction variable.
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpStore
			operands: { variable . value })
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitStructureType: structureType [
	| types |
	^ self valueTranslation: structureType do: [ :id |
		types := structureType types collect: [:type | self translateValue: type ].
		builder addTypeInstruction: (SpirVInstruction
			opcode: SpvOpTypeStruct
			result: id
			operands: types
		).
		
		structureType name ifNotNil: [ 
			builder addDebugInstruction: (SpirVInstruction
				opcode: SpvOpName
				operands: { id } , structureType name asSpirVStringLiteral
			).
			
			structureType names doWithIndex: [ :name :index |
				builder addDebugInstruction: (SpirVInstruction
					opcode: SpvOpMemberName
					operands: { id . index - 1} , name asSpirVStringLiteral
				).
			].
		].

		structureType types doWithIndex: [ :type :index |
			(type isMatrixType or: [ type isArrayType and: [ type baseType isMatrixType ] ]) ifTrue: [
				| columnType |
				columnType := type isMatrixType ifTrue: [ type columnType ] ifFalse: [ type baseType  columnType ].
				builder addAnnotationInstruction: (SpirVInstruction
					opcode: SpvOpMemberDecorate
					operands: { id . index - 1 . SpvDecorationColMajor }
				).
				builder addAnnotationInstruction: (SpirVInstruction
					opcode: SpvOpMemberDecorate
					operands: { id . index - 1 . SpvDecorationMatrixStride . columnType size }
				)
			].
			
		].
		
		structureType offsets doWithIndex: [ :offset :index |
			builder addAnnotationInstruction: (SpirVInstruction
				opcode: SpvOpMemberDecorate
				operands: { id . index - 1 . SpvDecorationOffset . offset }
			)
		].
	
		structureType kind = DASLStructureType blockKind ifTrue: [ 
			builder addAnnotationInstruction: (SpirVInstruction
				opcode: SpvOpDecorate
				operands: { id . SpvDecorationBlock }
			)
		].
	
		structureType kind = DASLStructureType bufferBlockKind ifTrue: [ 
			builder addAnnotationInstruction: (SpirVInstruction
				opcode: SpvOpDecorate
				operands: { id . SpvDecorationBufferBlock }
			)
		].
	
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitTextureType: textureType [
	| sampledType |
	^ self valueTranslation: textureType do: [ :id |
		sampledType := self translateValue: textureType sampledType.
		builder addTypeInstruction: (SpirVInstruction
			opcode: SpvOpTypeImage
			result: id
			operands: {
				sampledType .
				textureType dimensions - 1.
				textureType depth asBit .
				textureType array asBit .
				textureType multisample asBit .
				textureType sampled asBit .
				"Unknown format" 0}
		)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitUnaryOperation: unaryOp [
	| opcode resultType operand |
	^ self instructionTranslation: unaryOp do: [ :id |
		opcode := UnaryOperationMap at: unaryOp operation.
		resultType := self translateValue: unaryOp type.
		operand := self translateValue: unaryOp operand.
		builder addFunctionInstruction: (SpirVInstruction
			opcode: opcode
			type: resultType
			result: id
			operands: { operand }
		)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitUnreachable: unreachableInstruction [
	| returnType returnValueType returnValue |
	^ self instructionTranslation: unreachableInstruction do: [ :id |
		returnType := currentFunction functionType returnType.
		returnType isVoidType ifTrue: [ 
			builder addFunctionInstruction: (SpirVInstruction
				opcode: SpvOpReturn)
		] ifFalse: [
			returnValueType := self translateValue: returnType.
			returnValue := builder newId.
			builder addFunctionInstruction: (SpirVInstruction 
				opcode: SpvOpUndef
				type: returnValueType
				result: returnValue).
			builder addFunctionInstruction: (SpirVInstruction
				opcode: SpvOpReturnValue
				operands: {returnValue})
		]
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitVectorType: vectorType [
	| baseType |
	^ self valueTranslation: vectorType do: [ :id |
		baseType := self translateValue: vectorType baseType.
		builder addTypeInstruction: (SpirVInstruction opcode: SpvOpTypeVector result: id operands: {baseType . vectorType elements})
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitVoidType: voidType [
	^ self valueTranslation: voidType do: [ :id |
		builder addTypeInstruction: (SpirVInstruction
			opcode: SpvOpTypeVoid
			result: id
		)
	]
]

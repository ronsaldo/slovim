Class {
	#name : #SLVMSpirVCodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'translatedValues',
		'builder',
		'basicBlockDictionary',
		'instructionDictionary',
		'currentFunction',
		'compilationTarget',
		'outputStageBlockVariable',
		'valueReplacements',
		'inputStageBlockVariable',
		'emittedNames',
		'logicalAddressMode',
		'globalInterfaceList',
		'perFunctionInterfaceList'
	],
	#classVars : [
		'BinaryOperationMap',
		'BlockBuiltIns',
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
		'vector.cross' (glsl450 GLSLstd450Cross)
		'vector.dot' (SpirV SpvOpDot)
		'vector.length' (glsl450 GLSLstd450Length)
		'vector.normalize' (glsl450 GLSLstd450Normalize)
		'vector.reflect' (glsl450 GLSLstd450Reflect)
		'vector.refract' (glsl450 GLSLstd450Refract)
	
		'math.smoothstep' (glsl450 GLSLstd450SmoothStep)
		'math.step' (glsl450 GLSLstd450Step)
		
		'math.pow' (glsl450 GLSLstd450Pow) 
		'math.atan2' (glsl450 GLSLstd450Atan2) 
		
		'math.asin' (glsl450 GLSLstd450Asin) 
		'math.sin' (glsl450 GLSLstd450Sin)
		'math.asinh' (glsl450 GLSLstd450Asinh)
		'math.sinh' (glsl450 GLSLstd450Sinh)
		
		'math.acos' (glsl450 GLSLstd450Acos) 
		'math.cos' (glsl450 GLSLstd450Cos)
		'math.acosh' (glsl450 GLSLstd450Acosh)
		'math.cosh' (glsl450 GLSLstd450Cosh)
		
		'math.atan' (glsl450 GLSLstd450Atan)
		'math.tan' (glsl450 GLSLstd450Tan)
		'math.atanh' (glsl450 GLSLstd450Atanh)
		
		'math.exp' (glsl450 GLSLstd450Exp)
		'math.exp2' (glsl450 GLSLstd450Exp2)
		'math.log' (glsl450 GLSLstd450Log)
		'math.log2' (glsl450 GLSLstd450Log2)
		
		'math.sqrt' (glsl450 GLSLstd450Sqrt)
		'math.inverseSqrt' (glsl450 GLSLstd450InverseSqrt)
		'math.floor' (glsl450 GLSLstd450Floor)
		'math.ceil' (glsl450 GLSLstd450Ceil)
		'math.trunc' (glsl450 GLSLstd450Trunc)
		'math.round' (glsl450 GLSLstd450Round)
		'math.roundEven' (glsl450 GLSLstd450RoundEven)
		'math.fract' (glsl450 GLSLstd450Fract)
		
		'math.degrees' (glsl450 GLSLstd450Degrees)
		'math.radians' (glsl450 GLSLstd450Radians)
		'math.fabs' (glsl450 GLSLstd450FAbs)
		
		'math.fsign' (glsl450 GLSLstd450FSign)
			
		'math.smin' (glsl450 GLSLstd450SMin)
		'math.umin' (glsl450 GLSLstd450UMin)
		'math.fmin' (glsl450 GLSLstd450FMin)

		'math.smax' (glsl450 GLSLstd450SMax)
		'math.umax' (glsl450 GLSLstd450UMax)
		'math.fmax' (glsl450 GLSLstd450FMax)
		
		'math.fmix' (glsl450 GLSLstd450FMix)
		
		'matrix.transpose' (SpirV SpvOpTranspose)
	) pairsDo: [ :k :v |
		value := (SpirVConstants bindingOf: v second) value.
		self assert: value isNotNil.
		BuiltInExtensionInstructionMap at: k put: { v first . value }
	].

	BlockBuiltIns := Set newFrom: (#(
		SpvBuiltInPosition
		SpvBuiltInPointSize
		SpvBuiltInClipDistance
		SpvBuiltInCullDistance
	) collect: [ :v | ((SpirVConstants bindingOf: v) value + 1) negated ])
]

{ #category : #'code generation' }
SLVMSpirVCodeGenerator >> addBuiltIn: builtIn replacementStructure: structureVariable member: member [
	| memberConstant |
	memberConstant := SLVMConstant int: member.
	
	self addValue: builtIn replacement: [
		| result pointerType |
		
		"Get the member pointer."
		result := builder newId.
		pointerType := self translateValue: builtIn type.
		builder addFunctionInstruction: (SpirVInstruction opcode: SpvOpInBoundsAccessChain
			type: pointerType 
			result: result
			operands: { structureVariable . self translateValue: memberConstant}).
		result
	]
]

{ #category : #'code generation' }
SLVMSpirVCodeGenerator >> addStructure: structureId member: memberIndex annotations: annotations [
	annotations pairsDo: [ :annotation :value |
		annotation == #location ifTrue: [
			value >= 0 ifTrue: [ 
				builder addAnnotationInstruction: (SpirVInstruction
					opcode: SpvOpMemberDecorate
					operands: { structureId . memberIndex . SpvDecorationLocation . value  }
				).
			] ifFalse: [
				builder addAnnotationInstruction: (SpirVInstruction
					opcode: SpvOpMemberDecorate
					operands: { structureId . memberIndex . SpvDecorationBuiltIn . -1 - value  }
				).
			]
		].
	].
]

{ #category : #'code generation' }
SLVMSpirVCodeGenerator >> addStructure: structureId memberAnnotations: memberAnnotations [
	memberAnnotations doWithIndex: [ :annotations :memberIndex |
		self addStructure: structureId member: memberIndex - 1 annotations: annotations
	].
]

{ #category : #'code generation' }
SLVMSpirVCodeGenerator >> addValue: value replacement: replacementBlock [
	valueReplacements at: value put: replacementBlock
]

{ #category : #'as yet unclassified' }
SLVMSpirVCodeGenerator >> basicBlockLabelId: basicBlock [
	^ basicBlockDictionary at: basicBlock ifAbsentPut: [ builder newId ].
]

{ #category : #'code generation' }
SLVMSpirVCodeGenerator >> emitValue: value name: name [
	"Do not emit duplicated names. This crashes the NVIDIA driver."
	(emittedNames includes: name) ifTrue: [ ^ self ].
	
	emittedNames add: name.
	builder addDebugInstruction: (SpirVInstruction
		opcode: SpvOpName
		operands: { value } , name asSpirVStringLiteral
	).

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

{ #category : #visitor }
SLVMSpirVCodeGenerator >> getFunctionInterfaceList: function [
	| interfaceList |
	self perFunctionInterfaceList at: function ifPresent: [ :result | ^ result ].
	self perFunctionInterfaceList at: function put: #().
	interfaceList := SLVMOrderedInsertionSet new.
	 
	function allInstructionsDo: [ :instruction |
		instruction allParametersDo: [ :param |
			"Process the functions recursively"
			param isFunction ifTrue: [
				interfaceList addAll: (self getFunctionInterfaceList: param).
			].

			"Process the global variables."
			param isGlobalVariable ifTrue: [
				((param hasProperty: #location) or: [ param hasProperty: #shaderInterface]) ifTrue: [
					interfaceList add: (self translateValue: param)
				].
			].
		]
	].
	
	^ self perFunctionInterfaceList at: function put: interfaceList asArray.
]

{ #category : #initialization }
SLVMSpirVCodeGenerator >> initialize [
	super initialize.
	translatedValues := Dictionary new.
	basicBlockDictionary := Dictionary new.
	instructionDictionary := Dictionary new.
	valueReplacements := Dictionary new.
	globalInterfaceList := OrderedCollection new.
	emittedNames := Set new.
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

{ #category : #accessing }
SLVMSpirVCodeGenerator >> logicalAddressMode [
	^ logicalAddressMode
]

{ #category : #accessing }
SLVMSpirVCodeGenerator >> logicalAddressMode: aBoolean [
	logicalAddressMode := aBoolean
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> perFunctionInterfaceList [
	^ perFunctionInterfaceList ifNil: [ perFunctionInterfaceList := IdentityDictionary new ]
]

{ #category : #initialization }
SLVMSpirVCodeGenerator >> target: aCompilationTarget [
	compilationTarget := aCompilationTarget
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
	^ self translateModule: ssaModule exportList: (ssaModule allGlobalValues select: [:value | self isEntryPointFunction: value])
]

{ #category : #'code generation' }
SLVMSpirVCodeGenerator >> translateModule: ssaModule exportList: exportList [
	compilationTarget ifNil: [compilationTarget := ssaModule compilationTarget].
	^ SpirVModuleBuilder build: [ :builderArg |
		builder := builderArg.
		exportList do: [ :value | self translateValue: value ]
	]
]

{ #category : #'code generation' }
SLVMSpirVCodeGenerator >> translateValue: aValue [
	valueReplacements at: aValue ifPresent: [ :replacementBlock | ^ replacementBlock value ].
	^ translatedValues at: aValue ifPresent: [ :existing |
		existing ifNil: [ translatedValues at: aValue put: builder newId ]
	] ifAbsent: [
		aValue isInstruction ifTrue: [ ^ self generateLazyInstructionId: aValue ].
		aValue accept: self
	]
]

{ #category : #accessing }
SLVMSpirVCodeGenerator >> useGlobalInterfaceList [
	^ useGlobalInterfaceList
]

{ #category : #accessing }
SLVMSpirVCodeGenerator >> useGlobalInterfaceList: aBoolean [
	useGlobalInterfaceList := aBoolean
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

{ #category : #'as yet unclassified' }
SLVMSpirVCodeGenerator >> valueTranslation: aValue prepare: aPrepareBlock do: aBlock [
	| valueId preparationResult |
	(aValue isType not and: [aValue isInstruction]) ifTrue: [ ^ instructionDictionary at: aValue ifAbsentPut: [ builder newId ]].
	translatedValues at: aValue put: nil.
	preparationResult := aPrepareBlock value.
	
	valueId := (translatedValues at: aValue) ifNil: [
		translatedValues at: aValue put: builder newId
	].
	aBlock value: valueId value: preparationResult.
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
SLVMSpirVCodeGenerator >> visitConstantArrayValue: constantVectorValue [
	| slots type |
	^ self valueTranslation: constantVectorValue do: [ :id |
		type := self translateValue: constantVectorValue type.
		slots := constantVectorValue slots collect: [:slot | self translateValue: slot].
		
		builder addConstantInstruction: (SpirVInstruction
			opcode: SpvOpConstantComposite
			type: type
			result: id
			operands: slots
		) 
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitConstantMatrixValue: constantVectorValue [
	| slots type |
	^ self valueTranslation: constantVectorValue do: [ :id |
		type := self translateValue: constantVectorValue type.
		slots := constantVectorValue slots collect: [:slot | self translateValue: slot].
		
		builder addConstantInstruction: (SpirVInstruction
			opcode: SpvOpConstantComposite
			type: type
			result: id
			operands: slots
		) 
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitConstantStructureValue: constantVectorValue [
	| slots type |
	^ self valueTranslation: constantVectorValue do: [ :id |
		type := self translateValue: constantVectorValue type.
		slots := constantVectorValue slots collect: [:slot | self translateValue: slot].
		
		builder addConstantInstruction: (SpirVInstruction
			opcode: SpvOpConstantComposite
			type: type
			result: id
			operands: slots
		) 
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
SLVMSpirVCodeGenerator >> visitConstantVectorValue: constantVectorValue [
	| slots type |
	^ self valueTranslation: constantVectorValue do: [ :id |
		type := self translateValue: constantVectorValue type.
		slots := constantVectorValue slots collect: [:slot | self translateValue: slot].
		
		builder addConstantInstruction: (SpirVInstruction
			opcode: SpvOpConstantComposite
			type: type
			result: id
			operands: slots
		) 
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitDiscardFragment: discardInstruction [
	^ self instructionTranslation: discardInstruction do: [ :id |
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpKill)
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
SLVMSpirVCodeGenerator >> visitFloatToIntCast: instruction [
	| resultType source |
	^ self instructionTranslation: instruction do: [ :id |
		resultType := self translateValue: instruction type.
		source := self translateValue: instruction source.
		builder addFunctionInstruction: (SpirVInstruction
			opcode: (instruction type isUnsigned ifTrue: [SpvOpConvertFToU] ifFalse: [ SpvOpConvertFToS ])
			type: resultType
			result: id
			operands: { source }
		)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitFloatType: floatType [
	^ self valueTranslation: floatType do: [ :id |
		builder addTypeInstruction: (SpirVInstruction opcode: SpvOpTypeFloat result: id operands: {floatType size*8})
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
				operands: { SpvExecutionModelVertex . id . } , function name asSpirVStringLiteral , (self getFunctionInterfaceList: function)
			).
		].
		function propertyAt: #fragment ifPresent: [ :dummy |
			builder addEntryPointInstruction: (SpirVInstruction
				opcode: SpvOpEntryPoint
				operands: { SpvExecutionModelFragment . id . } , function name asSpirVStringLiteral , (self getFunctionInterfaceList: function)
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
SLVMSpirVCodeGenerator >> visitGetElementPointer: getElementPointer [
	| resultType pointer indices rawIndices hasNonConstantIndex |
	^ self instructionTranslation: getElementPointer do: [ :id |
		pointer := self translateValue: getElementPointer pointer.
		rawIndices := getElementPointer indices.
		indices := rawIndices collect: [:index | self translateValue: index ].
		resultType := self translateValue: getElementPointer type.
		getElementPointer isElementAccess ifTrue: [ 
			hasNonConstantIndex := rawIndices detect: [:index | index isConstant not] ifFound:[true] ifNone: [false].
			builder addFunctionInstruction: (SpirVInstruction
				opcode: (hasNonConstantIndex ifTrue: [ SpvOpAccessChain ] ifFalse: [ SpvOpInBoundsAccessChain ]) 
				type: resultType
				result: id
				operands: { pointer } , indices allButFirst)
		] ifFalse: [ 
			builder addFunctionInstruction: (SpirVInstruction
				opcode: SpvOpPtrAccessChain
				type: resultType
				result: id
				operands: { pointer } , indices)
		]
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
		
		self emitValue: id name: globalVariable name.
		globalVariable propertyAt: #location ifPresent: [ :location |
			globalInterfaceList add: id.
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
SLVMSpirVCodeGenerator >> visitIntToFloatCast: instruction [
	| resultType source |
	^ self instructionTranslation: instruction do: [ :id |
		resultType := self translateValue: instruction type.
		source := self translateValue: instruction source.
		builder addFunctionInstruction: (SpirVInstruction
			opcode: (instruction source type isUnsigned ifTrue: [SpvOpConvertUToF] ifFalse: [ SpvOpConvertSToF ])
			type: resultType
			result: id
			operands: { source }
		)
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitIntegerType: integerType [
	^ self valueTranslation: integerType do: [ :id |
		builder addTypeInstruction: (SpirVInstruction opcode: SpvOpTypeInt result: id operands: {integerType size * 8. integerType isSigned asBit})
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
		self assert: arguments size > 1.
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
		self assert: arguments size > 1.
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
SLVMSpirVCodeGenerator >> visitPointerType: pointerType [
	| storage |
	^ self valueTranslation: pointerType
		prepare: [ self translateValue: pointerType baseType ]
		do: [ :id :baseType |
		storage := StorageClassMap at: pointerType storage.
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
SLVMSpirVCodeGenerator >> visitSampleDepthRefImplicitLod: ssaInstruction [
	| sampledTexture texcoord resultType depthReference requiredCoordinates providedCoordinates combinedTexcoordDepthRef combinedTexcoordDepthRefType |
	^ self instructionTranslation: ssaInstruction do: [ :id |
		sampledTexture := self translateValue: ssaInstruction sampledTexture.
		texcoord := self translateValue: ssaInstruction texcoord.
		depthReference := self translateValue: ssaInstruction depthReference.
		
		"This is a hack for a NVIDIA bug."
		requiredCoordinates := ssaInstruction sampledTexture type texture requiredCoordinates.
		providedCoordinates := ssaInstruction texcoord type elements.
		(requiredCoordinates < 4 and: [ providedCoordinates = requiredCoordinates ]) ifTrue: [
			
			combinedTexcoordDepthRef := builder newId.
			combinedTexcoordDepthRefType := SLVMType floatVectorTypes at: providedCoordinates + 1.
			
			builder addFunctionInstruction: (SpirVInstruction
				opcode: SpvOpCompositeConstruct
				type: (self translateValue: combinedTexcoordDepthRefType)
				result: combinedTexcoordDepthRef
				operands: { texcoord . depthReference }).
			
			texcoord := combinedTexcoordDepthRef.
		].
	
		resultType := self translateValue: ssaInstruction type.
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpImageSampleDrefImplicitLod
			type: resultType
			result: id
			operands: { sampledTexture . texcoord . depthReference })
	]
]

{ #category : #visitor }
SLVMSpirVCodeGenerator >> visitSampleExplicitLod: sampleImplicitLod [
	| sampledTexture texcoord lod resultType |
	^ self instructionTranslation: sampleImplicitLod do: [ :id |
		sampledTexture := self translateValue: sampleImplicitLod sampledTexture.
		texcoord := self translateValue: sampleImplicitLod texcoord.
		lod := self translateValue: sampleImplicitLod lod.
		resultType := self translateValue: sampleImplicitLod type.
		builder addFunctionInstruction: (SpirVInstruction
			opcode: SpvOpImageSampleExplicitLod
			type: resultType
			result: id
			operands: { sampledTexture . texcoord . SpvImageOperandsLod . lod })
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

{ #category : #visiting }
SLVMSpirVCodeGenerator >> visitStructureType: structureType [
	^ self valueTranslation: structureType
		prepare: [ structureType types collect: [:type | self translateValue: type ] ]
		do: [ :id :types |
		builder addTypeInstruction: (SpirVInstruction
			opcode: SpvOpTypeStruct
			result: id
			operands: types
		).
		
		structureType name ifNotNil: [
			self emitValue: id name: structureType name.			
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
		
		structureType kind ~= SLVMStructureType builtInBlockKind ifTrue: [ 
			structureType offsets doWithIndex: [ :offset :index |
				builder addAnnotationInstruction: (SpirVInstruction
					opcode: SpvOpMemberDecorate
					operands: { id . index - 1 . SpvDecorationOffset . offset }
				)
			].
		].

		structureType memberAnnotations ifNotNil: [
			self addStructure: id memberAnnotations: structureType memberAnnotations
		].
	
		(structureType kind = SLVMStructureType blockKind or: 
		[ structureType kind = SLVMStructureType builtInBlockKind ]) ifTrue: [ 
			builder addAnnotationInstruction: (SpirVInstruction
				opcode: SpvOpDecorate
				operands: { id . SpvDecorationBlock }
			)
		].
	
		structureType kind = SLVMStructureType bufferBlockKind ifTrue: [ 
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

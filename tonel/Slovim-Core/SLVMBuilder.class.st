"
I am a builder for adding instructions into functions.
"
Class {
	#name : #SLVMBuilder,
	#superclass : #SLVMObject,
	#instVars : [
		'function',
		'currentBlock',
		'debugPositionStack',
		'allocaBuilder'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'instance creation' }
SLVMBuilder class >> on: aFunction [
	^ self new function: aFunction
]

{ #category : #arithmetic }
SLVMBuilder >> add: left with: right [
	^ self add: left with: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> add: left with: right name: resultName [
	^ self addOperation: #add left: left right: right name: resultName
]

{ #category : #adding }
SLVMBuilder >> addDynamicLiteral: literal [
	| objectModel |
	objectModel := function compilationTarget objectModel.
	(objectModel isInlineLiteral: literal) ifTrue: [ ^ objectModel convertInlineLiteral: literal ].
	^ function addDynamicLiteral: (objectModel convertNonInlineLiteral: literal)
]

{ #category : #adding }
SLVMBuilder >> addInstruction: anInstruction name: theInstructionName [
	anInstruction name: theInstructionName.
	debugPositionStack ifNotEmpty: [
		anInstruction debugSourceLocation: debugPositionStack top
	].
	currentBlock add: anInstruction.
	^ anInstruction
]

{ #category : #adding }
SLVMBuilder >> addOperation: operation left: left right: right [
	^ self addOperation: operation left: left right: right name: function generateSymbol
]

{ #category : #adding }
SLVMBuilder >> addOperation: operation left: left right: right name: name [
	^ self addInstruction: (SLVMBinaryOperation operation: operation left: left right: right) name: name
]

{ #category : #adding }
SLVMBuilder >> addOperation: operation operand: operand [
	^ self addOperation: operation operand: operand name: function generateSymbol
]

{ #category : #adding }
SLVMBuilder >> addOperation: operation operand: operand name: name [
	^ self addInstruction: (SLVMUnaryOperation operation: operation operand: operand) name: name
]

{ #category : #instructions }
SLVMBuilder >> alloca: valueType [
	^ self alloca: valueType name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> alloca: valueType name: variableName [
	^ self addInstruction: (SLVMAlloca pointerSize: self compilationTarget pointerSize valueType: valueType) name: variableName
]

{ #category : #accessing }
SLVMBuilder >> allocaBuilder [
	^ allocaBuilder
]

{ #category : #accessing }
SLVMBuilder >> allocaBuilder: anObject [
	allocaBuilder := anObject
]

{ #category : #testing }
SLVMBuilder >> areAllConstants: values [
	values do: [ :value | value isConstant ifFalse: [ ^ false ]].
	^ true
]

{ #category : #'logical operations' }
SLVMBuilder >> arithmeticShiftRight: left with: right [
	^ self arithmeticShiftRight: left with: right name: function generateSymbol
]

{ #category : #'logical operations' }
SLVMBuilder >> arithmeticShiftRight: left with: right name: resultName [
	^ self addOperation: #ashiftright left: left right: right name: resultName
]

{ #category : #'instance creation' }
SLVMBuilder >> basicBlock: aName do: aBlock [
	| basicBlock oldCurrentBlock |
	basicBlock := self newBasicBlock: aName.
	oldCurrentBlock := currentBlock.
	currentBlock := basicBlock.
	
	[ aBlock cull: self cull: basicBlock ] ensure: [ currentBlock := oldCurrentBlock ].
	^ basicBlock
]

{ #category : #'as yet unclassified' }
SLVMBuilder >> basicBlockNamed: basicBlockName do: aBlock [
	| bb |
	bb := self newBasicBlock: basicBlockName.
	self withBasicBlock: bb do: [ aBlock value: bb ].
	^ bb
]

{ #category : #'logical operations' }
SLVMBuilder >> bitAnd: left with: right [
	^ self bitAnd: left with: right name: function generateSymbol
]

{ #category : #'logical operations' }
SLVMBuilder >> bitAnd: left with: right name: resultName [
	^ self addOperation: #bitand left: left right: right name: resultName
]

{ #category : #casting }
SLVMBuilder >> bitCast: source target: targetType [
	^ self bitCast: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> bitCast: source target: targetType name: resultName [
	source type = targetType ifTrue: [ ^ source ].
	^ self addInstruction: (SLVMBitCast source: source targetType: targetType) name: resultName
]

{ #category : #'logical operations' }
SLVMBuilder >> bitOr: left with: right [
	^ self bitOr: left with: right name: function generateSymbol
]

{ #category : #'logical operations' }
SLVMBuilder >> bitOr: left with: right name: resultName [
	^ self addOperation: #bitor left: left right: right name: resultName
]

{ #category : #'logical operations' }
SLVMBuilder >> bitXor: left with: right [
	^ self bitXor: left with: right name: function generateSymbol
]

{ #category : #'logical operations' }
SLVMBuilder >> bitXor: left with: right name: resultName [
	^ self addOperation: #bitxor left: left right: right name: resultName
]

{ #category : #casting }
SLVMBuilder >> boolToDynamicObjectCast: source target: targetType [
	^ self boolToDynamicObjectCast: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> boolToDynamicObjectCast: source target: targetType name: resultName [
	^ self addInstruction: (SLVMBoolToDynamicObjectCast source: source targetType: targetType) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> branch: condition ifTrue: ifTrueBlock ifFalse: ifFalseBlock [
	^ self branch: condition ifTrue: ifTrueBlock ifFalse: ifFalseBlock name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> branch: condition ifTrue: ifTrueBlock ifFalse: ifFalseBlock name: resultName [
	(condition isUnaryOperation and: [ condition isLogicalNot ]) ifTrue: [ 
		^ self addInstruction: (SLVMBranch condition: condition operand ifTrue: ifFalseBlock ifFalse: ifTrueBlock) name: resultName
	].

	^ self addInstruction: (SLVMBranch condition: condition ifTrue: ifTrueBlock ifFalse: ifFalseBlock) name: resultName
]

{ #category : #intrinsics }
SLVMBuilder >> builtInFunctionName: name argumentTypes: argumentTypes returnType: returnType [
	| builtInFunctionType |
	builtInFunctionType := SLVMFunctionType arguments: argumentTypes returnType: returnType.
	^ SLVMConstantBuiltInFunction pointerSize: self pointerSize name: name functionType: builtInFunctionType.
]

{ #category : #instructions }
SLVMBuilder >> call: functionValue arguments: arguments [
	^ self call: functionValue arguments: arguments name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> call: functionValue arguments: arguments name: resultName [
	^ self addInstruction: (SLVMCall function: functionValue arguments: arguments) name: resultName
]

{ #category : #casting }
SLVMBuilder >> closureToDynamicObject: source target: targetType [
	^ self closureToDynamicObject: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> closureToDynamicObject: source target: targetType name: resultName [
	^ self addInstruction: (SLVMClosureToDynamicObject source: source targetType: targetType) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> combineSampler: sampler with: texture [
	^ self combineSampler: sampler with: texture name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> combineSampler: sampler with: texture name: resultName [
	^ self addInstruction: (SLVMCombineSamplerWithTexture sampler: sampler texture: texture) name: resultName
]

{ #category : #accessing }
SLVMBuilder >> compilationTarget [
	^ function compilationTarget
]

{ #category : #constants }
SLVMBuilder >> const: aValue type: aType [
	^ SLVMConstant type: aType value: aValue
]

{ #category : #constants }
SLVMBuilder >> constBool: aValue [
	^ SLVMConstant bool: aValue
]

{ #category : #constants }
SLVMBuilder >> constCString: aValue [
	^ SLVMConstant pointerToConstant: (SLVMConstant cstring: aValue) pointerType: (self pointerTypeFor: SLVMType charType)
]

{ #category : #constants }
SLVMBuilder >> constDouble: aValue [
	^ SLVMConstant type: self compilationTarget double value: aValue
]

{ #category : #constants }
SLVMBuilder >> constFloat: aValue [
	^ SLVMConstant float: aValue
]

{ #category : #constants }
SLVMBuilder >> constInt: aValue [
	^ SLVMConstant int: aValue
]

{ #category : #constants }
SLVMBuilder >> constLong: aValue [
	^ SLVMConstant long: aValue
]

{ #category : #constants }
SLVMBuilder >> constUInt: aValue [
	^ SLVMConstant uint: aValue
]

{ #category : #constants }
SLVMBuilder >> constULong: aValue [
	^ SLVMConstant ulong: aValue
]

{ #category : #intrinsics }
SLVMBuilder >> ctlz: aValue [
	"Count leading zeros."
	| intrinsic |
	intrinsic := self ctlzIntrinsicFor: aValue type.
	^ self call: intrinsic arguments: { aValue }
]

{ #category : #intrinsics }
SLVMBuilder >> ctlzIntrinsicFor: aType [
	"Count leading zeros."
	^ self builtInFunctionName: #'bitwise.ctlz' argumentTypes: { aType } returnType: aType
]

{ #category : #intrinsics }
SLVMBuilder >> ctpop: aValue [
	"Count population"
	| intrinsic |
	intrinsic := self ctpopIntrinsicFor: aValue type.
	^ self call: intrinsic arguments: { aValue }
]

{ #category : #intrinsics }
SLVMBuilder >> ctpopIntrinsicFor: aType [
	"Count population"
	^ self builtInFunctionName: #'bitwise.ctpop' argumentTypes: { aType } returnType: aType
]

{ #category : #intrinsics }
SLVMBuilder >> cttz: aValue [
	"Count trailing zeros."
	| intrinsic |
	intrinsic := self cttzIntrinsicFor: aValue type.
	^ self call: intrinsic arguments: { aValue }
]

{ #category : #intrinsics }
SLVMBuilder >> cttzIntrinsicFor: aType [
	"Count trailing zeros."
	^ self builtInFunctionName: #'bitwise.ctlz' argumentTypes: { aType } returnType: aType
]

{ #category : #accessing }
SLVMBuilder >> currentBlock [
	^ currentBlock
]

{ #category : #accessing }
SLVMBuilder >> currentBlock: anObject [
	currentBlock := anObject
]

{ #category : #'debug information' }
SLVMBuilder >> debugDeclareVariable: variable [
	^ self debugDeclareVariable: variable name: function generateSymbol
]

{ #category : #'debug information' }
SLVMBuilder >> debugDeclareVariable: variable name: resultName [
	^ self addInstruction: (SLVMDebugInstructionDeclareVariable variable: variable) name: resultName
]

{ #category : #'debug information' }
SLVMBuilder >> debugSetVariable: variable value: value [
	^ self debugSetVariable: variable value: value name: function generateSymbol
]

{ #category : #'debug information' }
SLVMBuilder >> debugSetVariable: variable value: value name: resultName [
	^ self addInstruction: (SLVMDebugInstructionSetVariableValue variable: variable value: value) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> discardFragment [
	^ self discardFragment: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> discardFragment: resultName [
	^ self addInstruction: SLVMDiscardFragment new name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> div: left with: right [
	^ self div: left with: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> div: left with: right name: resultName [
	^ self addOperation: #div left: left right: right name: resultName
]

{ #category : #comparisons }
SLVMBuilder >> dynObjectIdentityEquals: left with: right [
	^ self dynObjectIdentityEquals: left with: right name: function generateSymbol
]

{ #category : #comparisons }
SLVMBuilder >> dynObjectIdentityEquals: left with: right name: resultName [
	^ self addOperation: #dynObjectIdentityEquals left: left right: right name: resultName
]

{ #category : #comparisons }
SLVMBuilder >> dynObjectIdentityNotEquals: left with: right [
	^ self dynObjectIdentityNotEquals: left with: right name: function generateSymbol
]

{ #category : #comparisons }
SLVMBuilder >> dynObjectIdentityNotEquals: left with: right name: resultName [
	^ self addOperation: #dynObjectIdentityNotEquals left: left right: right name: resultName
]

{ #category : #casting }
SLVMBuilder >> dynamicObjectToBoolCast: source target: targetType [
	^ self dynamicObjectToBoolCast: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> dynamicObjectToBoolCast: source target: targetType name: resultName [
	^ self addInstruction: (SLVMDynamicObjectToBoolCast source: source targetType: targetType) name: resultName
]

{ #category : #casting }
SLVMBuilder >> dynamicObjectToFloatCast: source target: targetType [
	^ self dynamicObjectToFloatCast: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> dynamicObjectToFloatCast: source target: targetType name: resultName [
	^ self addInstruction: (SLVMDynamicObjectToFloatCast source: source targetType: targetType) name: resultName
]

{ #category : #casting }
SLVMBuilder >> dynamicObjectToIntCast: source target: targetType [
	^ self dynamicObjectToIntCast: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> dynamicObjectToIntCast: source target: targetType name: resultName [
	^ self addInstruction: (SLVMDynamicObjectToIntCast source: source targetType: targetType) name: resultName
]

{ #category : #casting }
SLVMBuilder >> dynamicObjectToPointerCast: source target: targetType typeObject: typeObject [
	^ self dynamicObjectToPointerCast: source target: targetType typeObject: typeObject name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> dynamicObjectToPointerCast: source target: targetType typeObject: typeObject name: resultName [
	^ self addInstruction: (SLVMDynamicObjectToPointerCast source: source targetType: targetType typeObject: typeObject) name: resultName
]

{ #category : #casting }
SLVMBuilder >> dynamicObjectToStructureCast: source target: targetType typeObject: typeObject [
	^ self dynamicObjectToStructureCast: source target: targetType typeObject: typeObject name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> dynamicObjectToStructureCast: source target: targetType typeObject: typeObject name: resultName [
	^ self addInstruction: (SLVMDynamicObjectToStructureCast source: source targetType: targetType typeObject: typeObject) name: resultName
]

{ #category : #accessing }
SLVMBuilder >> dynamicObjectType [
	^ self compilationTarget dynamicObjectType
]

{ #category : #instructions }
SLVMBuilder >> extractValue: anAggregateValue indices: indicesValue [
	^ self extractValue: anAggregateValue indices: indicesValue name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> extractValue: anAggregateValue indices: indicesValue name: resultName [
	^ self addInstruction: (SLVMExtractValue aggregate: anAggregateValue indices: indicesValue) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> extractVector: aVectorValue element: indexValue [
	^ self extractVector: aVectorValue element: indexValue name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> extractVector: aVectorValue element: indexValue name: resultName [
	^ self addInstruction: (SLVMExtractVectorElement vector: aVectorValue index: indexValue) name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> fadd: left with: right [
	^ self fadd: left with: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> fadd: left with: right name: resultName [
	^ self addOperation: #fadd left: left right: right name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> fdiv: left with: right [
	^ self fdiv: left with: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> fdiv: left with: right name: resultName [
	^ self addOperation: #fdiv left: left right: right name: resultName
]

{ #category : #casting }
SLVMBuilder >> floatToDynamicObjectCast: source target: targetType [
	^ self floatToDynamicObjectCast: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> floatToDynamicObjectCast: source target: targetType name: resultName [
	^ self addInstruction: (SLVMFloatToDynamicObjectCast source: source targetType: targetType) name: resultName
]

{ #category : #casting }
SLVMBuilder >> floatToIntCast: source target: targetType [
	^ self floatToIntCast: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> floatToIntCast: source target: targetType name: resultName [
	^ self addInstruction: (SLVMFloatToIntCast source: source targetType: targetType) name: resultName
]

{ #category : #casting }
SLVMBuilder >> floatingPointCast: source target: targetType [
	^ self floatingPointCast: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> floatingPointCast: source target: targetType name: resultName [
	source type = targetType ifTrue: [ ^ source ].
	self assert: source type isVectorType = targetType isVectorType.
	
	^ self addInstruction: (SLVMFloatingPointCast source: source targetType: targetType) name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> fmul: left with: right [
	^ self fmul: left with: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> fmul: left with: right name: resultName [
	^ self addOperation: #fmul left: left right: right name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> fneg: operand [
	^ self fneg: operand name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> fneg: operand name: resultName [
	^ self addOperation: #fneg operand: operand name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> frem: left with: right [
	^ self frem: left with: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> frem: left with: right name: resultName [
	^ self addOperation: #frem left: left right: right name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> fsqrt: operand [
	^ self fsqrt: operand name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> fsqrt: operand name: resultName [
	^ self addOperation: #fsqrt operand: operand name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> fsub: left with: right [
	^ self fsub: left with: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> fsub: left with: right name: resultName [
	^ self addOperation: #fsub left: left right: right name: resultName
]

{ #category : #accessing }
SLVMBuilder >> function [
	^ function
]

{ #category : #accessing }
SLVMBuilder >> function: anObject [
	function := anObject
]

{ #category : #instructions }
SLVMBuilder >> getFramePointer [
	^ self getFramePointer: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> getFramePointer: resultName [
	^ self addInstruction: (SLVMGetFramePointer type: function compilationTarget voidPointerType) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> getPointer: pointer element: element [
	^ self getPointer: pointer element: element resultName: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> getPointer: reference element: element resultName: resultName [
	^ self addInstruction: (SLVMGetElementPointer pointer: reference indices: element) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> getReference: reference element: element [
	^ self getReference: reference element: element resultName: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> getReference: reference element: element resultName: resultName [
	^ self getPointer: reference element: {self constInt: 0 . element } resultName: resultName
]

{ #category : #instructions }
SLVMBuilder >> getThisContext [
	^ self getThisContext: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> getThisContext: resultName [
	^ self addInstruction: (SLVMGetThisContext type: function compilationTarget dynamicObjectType) name: resultName
]

{ #category : #intrinsics }
SLVMBuilder >> highBit: aValue [
	| leadingZeros |
	leadingZeros := self ctlz: aValue.
	^ self sub:
		(self const: aValue type size * 8 type: aValue type )
		with: leadingZeros
]

{ #category : #comparisons }
SLVMBuilder >> ieq: left with: right [
	^ self ieq: left with: right name: function generateSymbol
]

{ #category : #comparisons }
SLVMBuilder >> ieq: left with: right name: resultName [
	^ self addOperation: #ieq left: left right: right name: resultName
]

{ #category : #comparisons }
SLVMBuilder >> ige: left with: right [
	^ self ige: left with: right name: function generateSymbol
]

{ #category : #comparisons }
SLVMBuilder >> ige: left with: right name: resultName [
	^ self addOperation: #ige left: left right: right name: resultName
]

{ #category : #comparisons }
SLVMBuilder >> igt: left with: right [
	^ self igt: left with: right name: function generateSymbol
]

{ #category : #comparisons }
SLVMBuilder >> igt: left with: right name: resultName [
	^ self addOperation: #igt left: left right: right name: resultName
]

{ #category : #comparisons }
SLVMBuilder >> ile: left with: right [
	^ self ile: left with: right name: function generateSymbol
]

{ #category : #comparisons }
SLVMBuilder >> ile: left with: right name: resultName [
	^ self addOperation: #ile left: left right: right name: resultName
]

{ #category : #comparisons }
SLVMBuilder >> ilt: left with: right [
	^ self ilt: left with: right name: function generateSymbol
]

{ #category : #comparisons }
SLVMBuilder >> ilt: left with: right name: resultName [
	^ self addOperation: #ilt left: left right: right name: resultName
]

{ #category : #comparisons }
SLVMBuilder >> ine: left with: right [
	^ self ine: left with: right name: function generateSymbol
]

{ #category : #comparisons }
SLVMBuilder >> ine: left with: right name: resultName [
	^ self addOperation: #ine left: left right: right name: resultName
]

{ #category : #initialization }
SLVMBuilder >> initialize [
	super initialize.
	debugPositionStack := Stack new.
]

{ #category : #instructions }
SLVMBuilder >> insertValue: anAggregateValue value: value indices: indicesValue [
	^ self insertValue: anAggregateValue value: value indices: indicesValue name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> insertValue: anAggregateValue value: value indices: indicesValue name: resultName [
	^ self addInstruction: (SLVMInsertValue aggregate: anAggregateValue value: value indices: indicesValue) name: resultName
]

{ #category : #closures }
SLVMBuilder >> instantiateClosure: closureDefinition captures: captures [
	^ self instantiateClosure: closureDefinition captures: captures name: function generateSymbol
]

{ #category : #closures }
SLVMBuilder >> instantiateClosure: closureDefinition captures: captures name: resultName [
	^ self addInstruction: (SLVMInstantiateClosure definition: closureDefinition captures: captures) name: resultName
]

{ #category : #casting }
SLVMBuilder >> intCast: source target: targetType [
	^ self intCast: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> intCast: source target: targetType name: resultName [
	| sourceType baseSourceType baseTargetType|
	sourceType := source type.
	sourceType = targetType ifTrue: [ ^ source ].
	self assert: sourceType isVectorType = targetType isVectorType .	
	baseSourceType := sourceType.
	baseTargetType := targetType.
	sourceType isVectorType ifTrue: [ 
		baseSourceType := sourceType baseType.
		baseTargetType := targetType baseType.
	].

	self assert: (baseSourceType isIntegerType and: [baseTargetType isIntegerType]).
	baseSourceType size = baseTargetType size ifTrue: [
		^ self bitCast: source target: targetType name: resultName
	] ifFalse: [ 
		baseTargetType size < baseSourceType size ifTrue: [
			^ self truncate: source target: targetType name: resultName
		] ifFalse: [ 
			baseSourceType isSigned ifTrue: [ 
				self flag: 'Check whether this is the correct case for performing sign extension'.
				^ self signExtend: source target: targetType name: resultName
			] ifFalse: [
				^ self zeroExtend: source target: targetType name: resultName
			]
		]
	]
]

{ #category : #casting }
SLVMBuilder >> intToDynamicObjectCast: source target: targetType [
	^ self intToDynamicObjectCast: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> intToDynamicObjectCast: source target: targetType name: resultName [
	source isConstantValue ifTrue: [
		self assert: source type isIntegerType.
		^ self addDynamicLiteral: source value
	].
	^ self addInstruction: (SLVMIntToDynamicObjectCast source: source targetType: targetType) name: resultName
]

{ #category : #casting }
SLVMBuilder >> intToFloatCast: source target: targetType [
	^ self intToFloatCast: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> intToFloatCast: source target: targetType name: resultName [
	^ self addInstruction: (SLVMIntToFloatCast source: source targetType: targetType) name: resultName
]

{ #category : #casting }
SLVMBuilder >> intToPointerCast: source target: targetType [
	^ self intToPointerCast: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> intToPointerCast: source target: targetType name: resultName [
	^ self addInstruction: (SLVMIntToPointerCast source: source targetType: targetType) name: resultName
]

{ #category : #'matrix operations' }
SLVMBuilder >> isFloatingPointMatrix: matrix [
	| type |
	type := matrix type.
	self assert: type isMatrixType.
	^ type baseType isFloatType
]

{ #category : #'vector arithmetic' }
SLVMBuilder >> isFloatingPointVector: vector [
	| type |
	type := vector type.
	self assert: type isVectorType.
	^ type baseType isFloatType
]

{ #category : #testing }
SLVMBuilder >> isLastTerminator [
	^ currentBlock isLastTerminator
]

{ #category : #'matrix operations' }
SLVMBuilder >> isSignedMatrix: matrix [
	| type |
	type := matrix type.
	self assert: type isMatrixType.
	^ type baseType isIntegerType and: [ type baseType isSigned ]
]

{ #category : #'vector arithmetic' }
SLVMBuilder >> isSignedVector: vector [
	| type |
	type := vector type.
	self assert: type isVectorType.
	^ type baseType isIntegerType and: [ type baseType isSigned ]
]

{ #category : #'matrix operations' }
SLVMBuilder >> isUnsignedMatrix: matrix [
	| type |
	type := matrix type.
	self assert: type isMatrixType.
	^ type baseType isIntegerType and: [ type baseType isUnsigned ]
]

{ #category : #'vector arithmetic' }
SLVMBuilder >> isUnsignedVector: vector [
	| type |
	type := vector type.
	self assert: type isVectorType.
	^ type baseType isIntegerType and: [ type baseType isUnsigned ]
]

{ #category : #instructions }
SLVMBuilder >> jump: destination [
	^ self jump: destination name: function generateSymbol

]

{ #category : #instructions }
SLVMBuilder >> jump: destination name: resultName [
	^ self addInstruction: (SLVMJump destination: destination) name: resultName
]

{ #category : #accessing }
SLVMBuilder >> lastInstruction [
	^ currentBlock lastInstruction
]

{ #category : #'logical operations' }
SLVMBuilder >> lnot: operand [
	^ self lnot: operand name: function generateSymbol
]

{ #category : #'logical operations' }
SLVMBuilder >> lnot: operand name: resultName [
	^ self addOperation: #lnot operand: operand name: resultName
]

{ #category : #instructions }
SLVMBuilder >> load: variable [
	^ self load: variable name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> load: variable name: resultName [
	^ self addInstruction: (SLVMLoadInstruction variable: variable) name: resultName
]

{ #category : #intrinsics }
SLVMBuilder >> lowBit: aValue [
	"https://en.wikipedia.org/wiki/Find_first_set"
	
	^ self sub: (self const: aValue type size * 8 type: aValue type)
		with: (self ctlz: (self bitAnd: aValue with: (self neg: aValue)))
]

{ #category : #instructions }
SLVMBuilder >> makeMatrix: matrixType arguments: arguments [
	^ self makeMatrix: matrixType arguments: arguments name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> makeMatrix: matrixType arguments: arguments name: resultName [
	self assert: arguments size > 1.
	(self areAllConstants: arguments) ifTrue: [ 
		^ SLVMConstantMatrixValue new type: matrixType; slots: arguments
	].

	^ self addInstruction: (SLVMMakeMatrix type: matrixType parameters: arguments) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> makeVector: vectorType arguments: arguments [
	^ self makeVector: vectorType arguments: arguments name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> makeVector: vectorType arguments: arguments name: resultName [
	self assert: arguments size > 1.
	(self areAllConstants: arguments) ifTrue: [ 
		^ SLVMConstantVectorValue new type: vectorType; slots: arguments
	].
	^ self addInstruction: (SLVMMakeVector type: vectorType parameters: arguments) name: resultName
]

{ #category : #'matrix operations' }
SLVMBuilder >> matrixAdd: left with: right [
	^ self matrixAdd: left with: right name: function generateSymbol
]

{ #category : #'matrix operations' }
SLVMBuilder >> matrixAdd: left with: right name: name [
	(self isFloatingPointMatrix: left) ifTrue: [
		^ self fadd: left with: right name: name
	] ifFalse: [ 
		^ self add: left with: right name: name
	]
]

{ #category : #'matrix operations' }
SLVMBuilder >> matrixDiv: left with: right [
	^ self matrixDiv: left with: right name: function generateSymbol
]

{ #category : #'matrix operations' }
SLVMBuilder >> matrixDiv: left with: right name: name [
	(self isFloatingPointMatrix: left) ifTrue: [
		^ self fdiv: left with: right name: name
	] ifFalse: [
		(self isSignedMatrix: left) ifTrue: [ 
			^ self div: left with: right name: name
		] ifFalse: [
			^ self udiv: left with: right name: name
		]
	]
]

{ #category : #'matrix operations' }
SLVMBuilder >> matrixMul: left with: right [
	^ self matrixMul: left with: right name: function generateSymbol
]

{ #category : #'matrix operations' }
SLVMBuilder >> matrixMul: left with: right name: name [
	(self isFloatingPointMatrix: left) ifTrue: [
		^ self fmul: left with: right name: name
	] ifFalse: [ 
		^ self mul: left with: right name: name
	]
]

{ #category : #'matrix operations' }
SLVMBuilder >> matrixRem: left with: right [
	^ self matrixRem: left with: right name: function generateSymbol
]

{ #category : #'matrix operations' }
SLVMBuilder >> matrixRem: left with: right name: name [
	(self isFloatingPointMatrix: left) ifTrue: [
		^ self frem: left with: right name: name
	] ifFalse: [
		(self isSignedMatrix: left) ifTrue: [ 
			^ self rem: left with: right name: name
		] ifFalse: [
			^ self urem: left with: right name: name
		]
	]
]

{ #category : #'matrix operations' }
SLVMBuilder >> matrixSub: left with: right [
	^ self matrixSub: left with: right name: function generateSymbol
]

{ #category : #'matrix operations' }
SLVMBuilder >> matrixSub: left with: right name: name [
	(self isFloatingPointMatrix: left) ifTrue: [
		^ self fsub: left with: right name: name
	] ifFalse: [ 
		^ self sub: left with: right name: name
	]
]

{ #category : #arithmetic }
SLVMBuilder >> mul: left with: right [
	^ self mul: left with: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> mul: left with: right name: resultName [
	^ self addOperation: #mul left: left right: right name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> mulMatrix: left withMatrix: right [
	^ self mulMatrix: left withMatrix: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> mulMatrix: left withMatrix: right name: resultName [
	^ self addOperation: #mulMatrixMatrix left: left right: right name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> mulMatrix: left withVector: right [
	^ self mulMatrix: left withVector: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> mulMatrix: left withVector: right name: resultName [
	^ self addOperation: #mulMatrixVector left: left right: right name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> mulVector: left withMatrix: right [
	^ self mulVector: left withMatrix: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> mulVector: left withMatrix: right name: resultName [
	^ self addOperation: #mulVectorMatrix left: left right: right name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> neg: operand [
	^ self neg: operand name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> neg: operand name: resultName [
	^ self addOperation: #neg operand: operand name: resultName
]

{ #category : #'instance creation' }
SLVMBuilder >> newBasicBlock [
	^ self newBasicBlock: function generateSymbol
]

{ #category : #'instance creation' }
SLVMBuilder >> newBasicBlock: aName [
	| block |
	block := SLVMBasicBlock new name: aName.
	function addBasicBlock: block.
	^ block.
]

{ #category : #'instance creation' }
SLVMBuilder >> newBasicBlockHere: aName [
	^ currentBlock := self newBasicBlock: aName
]

{ #category : #'logical operations' }
SLVMBuilder >> not: operand [
	^ self not: operand name: function generateSymbol
]

{ #category : #'logical operations' }
SLVMBuilder >> not: operand name: resultName [
	^ self addOperation: #not operand: operand name: resultName
]

{ #category : #comparisons }
SLVMBuilder >> ofeq: left with: right [
	^ self ofeq: left with: right name: function generateSymbol
]

{ #category : #comparisons }
SLVMBuilder >> ofeq: left with: right name: resultName [
	^ self addOperation: #ofeq left: left right: right name: resultName
]

{ #category : #comparisons }
SLVMBuilder >> ofge: left with: right [
	^ self ofge: left with: right name: function generateSymbol
]

{ #category : #comparisons }
SLVMBuilder >> ofge: left with: right name: resultName [
	^ self addOperation: #ofge left: left right: right name: resultName
]

{ #category : #comparisons }
SLVMBuilder >> ofgt: left with: right [
	^ self ofgt: left with: right name: function generateSymbol
]

{ #category : #comparisons }
SLVMBuilder >> ofgt: left with: right name: resultName [
	^ self addOperation: #ofgt left: left right: right name: resultName
]

{ #category : #comparisons }
SLVMBuilder >> ofle: left with: right [
	^ self ofle: left with: right name: function generateSymbol
]

{ #category : #comparisons }
SLVMBuilder >> ofle: left with: right name: resultName [
	^ self addOperation: #ofle left: left right: right name: resultName
]

{ #category : #comparisons }
SLVMBuilder >> oflt: left with: right [
	^ self oflt: left with: right name: function generateSymbol
]

{ #category : #comparisons }
SLVMBuilder >> oflt: left with: right name: resultName [
	^ self addOperation: #oflt left: left right: right name: resultName
]

{ #category : #comparisons }
SLVMBuilder >> ofne: left with: right [
	^ self ofne: left with: right name: function generateSymbol
]

{ #category : #comparisons }
SLVMBuilder >> ofne: left with: right name: resultName [
	^ self addOperation: #ofne left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> phi: type [
	^ self phi: type name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> phi: type name: resultName [
	^ self addInstruction: (SLVMPhi type: type) name: resultName
]

{ #category : #accessing }
SLVMBuilder >> pointerSize [
	^ self compilationTarget pointerSize
]

{ #category : #casting }
SLVMBuilder >> pointerToDynamicObjectCast: source target: targetType typeObject: typeObject [
	^ self pointerToDynamicObjectCast: source target: targetType typeObject: typeObject name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> pointerToDynamicObjectCast: source target: targetType typeObject: typeObject name: resultName [
	^ self addInstruction: (SLVMPointerToDynamicObjectCast source: source targetType: targetType typeObject: typeObject) name: resultName
]

{ #category : #casting }
SLVMBuilder >> pointerToIntCast: source target: targetType [
	^ self pointerToIntCast: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> pointerToIntCast: source target: targetType name: resultName [
	^ self addInstruction: (SLVMPointerToIntCast source: source targetType: targetType) name: resultName
]

{ #category : #accessing }
SLVMBuilder >> pointerTypeFor: baseType [
	^ SLVMPointerType size: self compilationTarget pointerSize baseType: baseType storage: SLVMType genericStorage
]

{ #category : #'debug information' }
SLVMBuilder >> popDebugSourcePosition [
	debugPositionStack pop
]

{ #category : #'debug information' }
SLVMBuilder >> pushDebugSourcePosition: debugPosition [
	debugPositionStack push: debugPosition
]

{ #category : #adding }
SLVMBuilder >> registerClassVariable: classVariable class: classVariableClass [
	function module registerClassVariable: classVariable class: classVariableClass
]

{ #category : #arithmetic }
SLVMBuilder >> rem: left with: right [
	^ self rem: left with: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> rem: left with: right name: resultName [
	^ self addOperation: #rem left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> return: value [
	^ self return: value name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> return: value fromContext: context [
	^ self return: value fromContext: context name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> return: value fromContext: context name: resultName [
	^ self addInstruction: (SLVMReturnFromContext value: value context: context) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> return: value name: resultName [
	self assert: function functionType returnType isVoidType not.
	^ self addInstruction: (SLVMReturn value: value) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> returnVoid [
	^ self returnVoid: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> returnVoid: resultName [
	self assert: function functionType returnType isVoidType.
	^ self addInstruction: SLVMReturnVoid new name: resultName
]

{ #category : #instructions }
SLVMBuilder >> returnVoidFromContext: context [
	^ self returnVoidFromContext: context name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> returnVoidFromContext: context name: resultName [
	^ self addInstruction: (SLVMReturnVoidFromContext context: context) name: resultName
]

{ #category : #sampling }
SLVMBuilder >> sample: combinedSampler explicitLod: lod atCoord: texcoord [
	^ self sample: combinedSampler explicitLod: lod atCoord: texcoord name: function generateSymbol
]

{ #category : #sampling }
SLVMBuilder >> sample: combinedSampler explicitLod: lod atCoord: texcoord name: resultName [
	^ self addInstruction: (SLVMSampleExplicitLod sampledTexture: combinedSampler texcoord: texcoord lod: lod) name: resultName
]

{ #category : #sampling }
SLVMBuilder >> sample: combinedSampler implicitLodAtCoord: texcoord [
	^ self sample: combinedSampler implicitLodAtCoord: texcoord name: function generateSymbol
]

{ #category : #sampling }
SLVMBuilder >> sample: combinedSampler implicitLodAtCoord: texcoord depthReference: depthReference [
	^ self sample: combinedSampler implicitLodAtCoord: texcoord depthReference: depthReference name: function generateSymbol
]

{ #category : #sampling }
SLVMBuilder >> sample: combinedSampler implicitLodAtCoord: texcoord depthReference: depthReference name: resultName [
	^ self addInstruction: (SLVMSampleDepthRefImplicitLod sampledTexture: combinedSampler texcoord: texcoord depthReference: depthReference) name: resultName
]

{ #category : #sampling }
SLVMBuilder >> sample: combinedSampler implicitLodAtCoord: texcoord name: resultName [
	^ self addInstruction: (SLVMSampleImplicitLod sampledTexture: combinedSampler texcoord: texcoord) name: resultName
]

{ #category : #sampling }
SLVMBuilder >> sampleDepth: combinedSampler implicitLodAtCoord: texcoord [
	^ self sampleDepth: combinedSampler implicitLodAtCoord: texcoord name: function generateSymbol
]

{ #category : #sampling }
SLVMBuilder >> sampleDepth: combinedSampler implicitLodAtCoord: texcoord name: resultName [
	^ self addInstruction: (SLVMSampleDepthImplicitLod sampledTexture: combinedSampler texcoord: texcoord) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> send: selector returnType: returnType receiver: receiver arguments: arguments [
	^ self send: selector returnType: returnType receiver: receiver arguments: arguments name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> send: selector returnType: returnType receiver: receiver arguments: arguments name: resultName [
	^ self addInstruction: (SLVMSendMessage returnType: returnType receiver: receiver selector: selector arguments: arguments) name: resultName
]

{ #category : #'logical operations' }
SLVMBuilder >> shiftLeft: left with: right [
	^ self shiftLeft: left with: right name: function generateSymbol
]

{ #category : #'logical operations' }
SLVMBuilder >> shiftLeft: left with: right name: resultName [
	^ self addOperation: #shiftleft left: left right: right name: resultName
]

{ #category : #'logical operations' }
SLVMBuilder >> shiftRight: left with: right [
	^ self shiftRight: left with: right name: function generateSymbol
]

{ #category : #'logical operations' }
SLVMBuilder >> shiftRight: left with: right name: resultName [
	^ self addOperation: #shiftright left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> shuffleVector: firstVector with: secondVector components: components [
	^ self shuffleVector: firstVector with: secondVector components: components name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> shuffleVector: firstVector with: secondVector components: components name: resultName [
	^ self addInstruction: (SLVMShuffleVectors firstVector: firstVector secondVector: secondVector components: components) name: resultName
]

{ #category : #casting }
SLVMBuilder >> signExtend: source target: targetType [
	^ self signExtend: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> signExtend: source target: targetType name: resultName [
	^ self addInstruction: (SLVMSignExtend source: source targetType: targetType) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> store: value in: variable [
	^ self store: value in: variable name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> store: value in: variable name: resultName [
	^ self addInstruction: (SLVMStoreInstruction value: value variable: variable) name: resultName
]

{ #category : #casting }
SLVMBuilder >> structureToDynamicObjectCast: source target: targetType typeObject: typeObject [
	^ self structureToDynamicObjectCast: source target: targetType typeObject: typeObject name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> structureToDynamicObjectCast: source target: targetType typeObject: typeObject name: resultName [
	^ self addInstruction: (SLVMStructureToDynamicObjectCast source: source targetType: targetType typeObject: typeObject) name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> sub: left with: right [
	^ self sub: left with: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> sub: left with: right name: resultName [
	^ self addOperation: #sub left: left right: right name: resultName
]

{ #category : #casting }
SLVMBuilder >> truncate: source target: targetType name: resultName [
	^ self addInstruction: (SLVMTruncate source: source targetType: targetType) name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> udiv: left with: right [
	^ self udiv: left with: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> udiv: left with: right name: resultName [
	^ self addOperation: #udiv left: left right: right name: resultName
]

{ #category : #comparisons }
SLVMBuilder >> ufeq: left with: right name: resultName [
	^ self addOperation: #ufeq left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> unreachable [
	^ self unreachable: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> unreachable: resultName [
	^ self addInstruction: SLVMUnreacheable new name: resultName
]

{ #category : #arithmetic }
SLVMBuilder >> urem: left with: right [
	^ self urem: left with: right name: function generateSymbol
]

{ #category : #arithmetic }
SLVMBuilder >> urem: left with: right name: resultName [
	^ self addOperation: #urem left: left right: right name: resultName
]

{ #category : #'vector arithmetic' }
SLVMBuilder >> vectorAdd: left with: right [
	^ self vectorAdd: left with: right name: function generateSymbol
]

{ #category : #'vector arithmetic' }
SLVMBuilder >> vectorAdd: left with: right name: name [
	(self isFloatingPointVector: left) ifTrue: [
		^ self fadd: left with: right name: name
	] ifFalse: [ 
		^ self add: left with: right name: name
	]
]

{ #category : #casting }
SLVMBuilder >> vectorCastFrom: source into: targetType [
	^ self vectorCastFrom: source into: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> vectorCastFrom: source into: targetType name: name [
	| sourceElementType targetElementType |
	self assert: source type elements = targetType elements.
	sourceElementType := source type baseType.
	targetElementType := targetType baseType.
	(sourceElementType isIntegerType and: [ targetElementType isFloatType ]) ifTrue: [ 
		^ self intToFloatCast: source target: targetType name: name
	].
	(sourceElementType isFloatType and: [ targetElementType isIntegerType ]) ifTrue: [ 
		^ self floatToIntCast: source target: targetType name: name
	].

	(sourceElementType isIntegerType and: [ targetElementType isIntegerType ]) ifTrue: [ 
		^ self intCast: source target: targetType name: name
	].

	(sourceElementType isFloatType and: [ targetElementType isFloatType ]) ifTrue: [ 
		^ self floatingPointCast: source target: targetType name: name
	].

	self error: 'Unsupported vector cast type.'
]

{ #category : #'vector arithmetic' }
SLVMBuilder >> vectorDiv: left with: right [
	^ self vectorDiv: left with: right name: function generateSymbol
]

{ #category : #'vector arithmetic' }
SLVMBuilder >> vectorDiv: left with: right name: name [
	(self isFloatingPointVector: left) ifTrue: [
		^ self fdiv: left with: right name: name
	] ifFalse: [
		(self isSignedVector: left) ifTrue: [ 
			^ self div: left with: right name: name
		] ifFalse: [
			^ self udiv: left with: right name: name
		]
	]
]

{ #category : #'vector arithmetic' }
SLVMBuilder >> vectorMul: left with: right [
	^ self vectorMul: left with: right name: function generateSymbol
]

{ #category : #'vector arithmetic' }
SLVMBuilder >> vectorMul: left with: right name: name [
	(self isFloatingPointVector: left) ifTrue: [
		^ self fsub: left with: right name: name
	] ifFalse: [ 
		^ self sub: left with: right name: name
	]
]

{ #category : #'vector arithmetic' }
SLVMBuilder >> vectorRem: left with: right [
	^ self vectorRem: left with: right name: function generateSymbol
]

{ #category : #'vector arithmetic' }
SLVMBuilder >> vectorRem: left with: right name: name [
	(self isFloatingPointVector: left) ifTrue: [
		^ self frem: left with: right name: name
	] ifFalse: [
		(self isSignedVector: left) ifTrue: [ 
			^ self rem: left with: right name: name
		] ifFalse: [
			^ self urem: left with: right name: name
		]
	]
]

{ #category : #'vector arithmetic' }
SLVMBuilder >> vectorSub: left with: right [
	^ self vectorSub: left with: right name: function generateSymbol
]

{ #category : #'vector arithmetic' }
SLVMBuilder >> vectorSub: left with: right name: name [
	(self isFloatingPointVector: left) ifTrue: [
		^ self fsub: left with: right name: name
	] ifFalse: [ 
		^ self sub: left with: right name: name
	]
]

{ #category : #'as yet unclassified' }
SLVMBuilder >> withBasicBlock: aBasicBlock do: aBlock [
	| oldCurrentBlock |
	oldCurrentBlock := currentBlock.
	currentBlock := aBasicBlock.
	aBlock ensure: [ currentBlock := oldCurrentBlock ]
]

{ #category : #casting }
SLVMBuilder >> zeroExtend: source target: targetType [
	^ self zeroExtend: source target: targetType name: function generateSymbol
]

{ #category : #casting }
SLVMBuilder >> zeroExtend: source target: targetType name: resultName [
	^ self addInstruction: (SLVMZeroExtend source: source targetType: targetType) name: resultName
]

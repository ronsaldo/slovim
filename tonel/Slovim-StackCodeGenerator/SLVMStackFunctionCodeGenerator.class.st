Class {
	#name : #SLVMStackFunctionCodeGenerator,
	#superclass : #Object,
	#instVars : [
		'moduleCodeGenerator',
		'slvmFunction',
		'etreeFunction',
		'translatedElements'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> addParametersOf: slvmInstruction into: etreeExpression [
	etreeExpression parameters: (slvmInstruction parameters collect: [ :param |
		self translateInstructionParameter: param.
	]).
	etreeExpression
		debugSourceLocation: slvmInstruction debugSourceLocation;
		debugInformation: slvmInstruction debugInformation.
	^ etreeExpression
]

{ #category : #'code generation' }
SLVMStackFunctionCodeGenerator >> createArguments [
	| etreeArg |
	slvmFunction arguments do: [ :arg |
		etreeArg := SLVMETreeFunctionArgument new
			name: arg name;
			type: arg type;
			flags: arg flags.
		etreeFunction addArgument: etreeArg.
		translatedElements at: arg put: etreeArg
	]
]

{ #category : #'as yet unclassified' }
SLVMStackFunctionCodeGenerator >> createBasicBlocks [
	| etreeBB |
	slvmFunction basicBlocks do: [ :bb |
		etreeBB := SLVMETreeBasicBlock new name: bb name.
		etreeFunction addBasicBlock: etreeBB.
		translatedElements at: bb put: etreeBB.
		self createTemporariesForBasicBlock: bb into: etreeBB
	].
]

{ #category : #'as yet unclassified' }
SLVMStackFunctionCodeGenerator >> createTemporariesForBasicBlock: slvmBasicBlock into: etreeBasicBlock [
	| etreeStatement |
	slvmBasicBlock instructionsDo: [ :instruction |
		etreeStatement := SLVMETreeStatement new slvmInstruction: instruction; type: instruction type.
		etreeBasicBlock add: etreeStatement.
		instruction type isVoidType ifFalse: [ 
			etreeStatement name: instruction name.
			translatedElements at: instruction put: etreeStatement
		].
	]
]

{ #category : #'as yet unclassified' }
SLVMStackFunctionCodeGenerator >> mergeExpressions [
	etreeFunction basicBlocks do: [ :bb |
		self mergeExpressionsInBasicBlock: bb
	]
]

{ #category : #'as yet unclassified' }
SLVMStackFunctionCodeGenerator >> mergeExpressionsInBasicBlock: bb [
	bb statementsDo: [ :statement | statement mergePreviousExpressions ]
]

{ #category : #accessing }
SLVMStackFunctionCodeGenerator >> moduleCodeGenerator [
	^ moduleCodeGenerator
]

{ #category : #accessing }
SLVMStackFunctionCodeGenerator >> moduleCodeGenerator: anObject [
	moduleCodeGenerator := anObject
]

{ #category : #'code generation' }
SLVMStackFunctionCodeGenerator >> translateBasicBlock: etreeBasicBlock [
	etreeBasicBlock statementsDo: [ :stmnt |
		self translateStatement: stmnt
	]
]

{ #category : #'code generation' }
SLVMStackFunctionCodeGenerator >> translateBasicBlocks [
	etreeFunction basicBlocks do: [ :bb | self translateBasicBlock: bb ]
]

{ #category : #'as yet unclassified' }
SLVMStackFunctionCodeGenerator >> translateFunction: aFunction into: expressionTreeFunction [
	slvmFunction := aFunction.
		
	slvmFunction applyDominanceTopoSort.
	etreeFunction := expressionTreeFunction.
	
	translatedElements := IdentityDictionary new.
	self createArguments.
	self createBasicBlocks.
	self translateBasicBlocks.
	self mergeExpressions.
]

{ #category : #'as yet unclassified' }
SLVMStackFunctionCodeGenerator >> translateInstructionParameter: parameter [
	^ translatedElements at: parameter ifAbsentPut: [ parameter accept: self ]

]

{ #category : #'code generation' }
SLVMStackFunctionCodeGenerator >> translateStatement: statement [
	statement expression: (statement slvmInstruction accept: self);
		addReferencesToOperands
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitAlloca: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeAllocaExpression new
		valueType: anInstruction valueType;
		type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitBinaryOperation: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeBinaryExpression new
			operation: anInstruction operation;
			type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitBitCast: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeBitCast new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitBoolToDynamicObjectCast: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeBoolToDynamicObjectCast new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitBranch: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeBranchExpression new
			trueBlock: (self translateInstructionParameter: anInstruction trueBlock);
			falseBlock: (self translateInstructionParameter: anInstruction falseBlock);
			type: anInstruction type
			yourself)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitCall: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeCallExpression new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitConstantDynamicLiteral: constant [
	^ SLVMETreeConstantDynamicLiteral new type: constant type; value: constant value
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitConstantValue: constant [
	^ SLVMETreeConstantValue new type: constant type; value: constant value
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitDynamicObjectToBoolCast: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeDynamicObjectToBoolCast new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitDynamicObjectToFloatCast: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeDynamicObjectToFloatCast new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitDynamicObjectToIntCast: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeDynamicObjectToIntCast new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitFloatToCast: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeFloatToIntCast new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitFloatToDynamicObjectCast: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeFloatToDynamicObjectCast new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitFloatingPointCast: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeFloatingPointCast new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitFunction: aFunction [
	^ moduleCodeGenerator translateModuleElement: aFunction
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitGetElementPointer: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeGetElementPointer new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitGlobalVariable: aFunction [
	^ moduleCodeGenerator translateModuleElement: aFunction
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitIntToDynamicObjectCast: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeIntToDynamicObjectCast new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitIntToFloatCast: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeIntToFloatCast new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitJump: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeJumpExpression new
			destination: (self translateInstructionParameter: anInstruction destination);
			type: anInstruction type
			yourself)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitLoad: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeLoadExpression new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitMessageSend: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeMessageSendExpression new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitReturn: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeReturnExpression new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitSignExtend: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeSignExtend new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitStore: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeStoreExpression new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitTruncate: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeTruncate new type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitUnaryOperation: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeUnaryExpression new
		operation: anInstruction operation;
		type: anInstruction type)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitZeroExtend: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeZeroExtend new type: anInstruction type)
]

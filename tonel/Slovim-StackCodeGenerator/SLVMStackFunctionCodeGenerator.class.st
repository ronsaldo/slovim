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
	^ etreeExpression
]

{ #category : #'code generation' }
SLVMStackFunctionCodeGenerator >> createArguments [
	| etreeArg |
	slvmFunction arguments do: [ :arg |
		etreeArg := SLVMETreeFunctionArgument new argument: arg.
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
		etreeStatement := SLVMETreeStatement new slvmInstruction: instruction.
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
		into: (SLVMETreeAllocaExpression new valueType: anInstruction valueType)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitBinaryOperation: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeBinaryExpression new operation: anInstruction operation)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitBranch: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeBranchExpression new
			trueBlock: (self translateInstructionParameter: anInstruction trueBlock);
			falseBlock: (self translateInstructionParameter: anInstruction falseBlock);
			yourself)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitCall: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeCallExpression new)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitFunction: aFunction [
	^ moduleCodeGenerator translateModuleElement: aFunction
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitJump: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeJumpExpression new
			destination: (self translateInstructionParameter: anInstruction destination)
			yourself)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitLoad: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeLoadExpression new)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitReturn: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeReturnExpression new)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitStore: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeStoreExpression new)
]

{ #category : #visiting }
SLVMStackFunctionCodeGenerator >> visitUnaryOperation: anInstruction [
	^ self addParametersOf: anInstruction
		into: (SLVMETreeUnaryExpression new operation: anInstruction operation)
]

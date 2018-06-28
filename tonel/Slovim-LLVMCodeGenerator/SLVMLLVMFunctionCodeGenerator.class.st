Class {
	#name : #SLVMLLVMFunctionCodeGenerator,
	#superclass : #Object,
	#instVars : [
		'target',
		'moduleTranslator',
		'function',
		'llvmFunction',
		'valueDictionary',
		'usedNames',
		'functionDebugScope'
	],
	#classVars : [
		'BinaryFloatComparisonOperationMap',
		'BinaryIntegerComparisonOperationMap',
		'BinaryOperationMap',
		'UnaryOperationMap'
	],
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #initialization }
SLVMLLVMFunctionCodeGenerator class >> initialize [
	BinaryOperationMap := Dictionary newFromPairs: #(
		add add
		sub sub
		mul mul
		div sdiv
		udiv udiv
		rem srem
		urem urem

		bitand and
		bitor or
		bitxor xor

		shiftleft shl
		shiftright lshr
		shiftrightarithmetic ashr

		fadd fadd
		fsub fsub
		fmul fmul
		fdiv fdiv
		frem frem
	).
	
	BinaryIntegerComparisonOperationMap := Dictionary newFromPairs: #(
		ilt slt
		ile sle
		ieq eq
		ine ne
		igt sgt
		ige sge

		ult ult
		ule ule
		ugt ugt
		uge uge

		dynObjectIdentityEquals eq
		dynObjectIdentityNotEquals ne
	).
	
	BinaryFloatComparisonOperationMap := Dictionary newFromPairs: #(
		uflt ult
		ufle ult
		ufeq ueq
		ufne une
		ufgt ugt
		ufge uge

		oflt olt
		ofle ole
		ofeq oeq
		ofne one
		ofgt ogt
		ofge oge
	).
	
	UnaryOperationMap := Dictionary newFromPairs: #(
		neg		visitUnaryNegation:
		not   visitUnaryNot:
		lnot  visitUnaryLogicalNot:

		fneg   visitUnaryFloatNegation:
		fsqrt  visitUnarySqrt:
	).
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> aggregate: sourceAggregate insertValue: value at: destIndex [
	^ LLVMInsertValueInst new
		type: sourceAggregate type;
		aggregate: sourceAggregate;
		element: value;
		indices: {destIndex};
		yourself
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> context [
	^ moduleTranslator context
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> convertDebugLocationFrom: slvmInstruction into: llvmInstruction [
	functionDebugScope ifNil: [ ^ self ].
	(self convertDebugSourceLocation: slvmInstruction debugSourceLocation debugInformation: slvmInstruction debugInformation) ifNotNil: [ :convertedLocation |
		llvmInstruction addDebugMetadata: convertedLocation
	]
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> convertDebugScope: debugScope [
	debugScope ifNil: [ ^ functionDebugScope ].
	self halt
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> convertDebugSourceLocation: debugSourceLocation debugInformation: debugInformation [
	| debugScope |
	debugSourceLocation ifNil: [ ^ nil ].
	debugScope := self convertDebugScope: (debugInformation ifNotNil: #scope).
	
	^ moduleTranslator convertDebugSourceLocation: debugSourceLocation withScope: debugScope
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> convertDebugVariable: debugInformation [
	^ moduleTranslator convertDebugVariable: debugInformation fallbackScopeInto: functionDebugScope
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> convertName: aName [
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

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> createProxyValues [
	| llvmBasicBlock proxy |
	function dominanceTopoSort do: [ :bb |
		llvmBasicBlock := LLVMBasicBlock for: self context name: (self convertName: bb name) parent: llvmFunction.
		valueDictionary at: bb put: llvmBasicBlock.
		
		bb instructionsDo: [ :ins |
			proxy := LLVMInstructionProxy new sourceValue: ins.
			valueDictionary at: ins put: proxy.
			llvmBasicBlock addNext: proxy
		]
	].
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> functionDebugScope [
	^ functionDebugScope
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> functionDebugScope: aDebugScope [
	functionDebugScope := aDebugScope
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> generateFunction: slvmFunction into: newLLVMFunction [
	slvmFunction isEmpty ifTrue: [ ^ newLLVMFunction ].
	
	function := slvmFunction.
	llvmFunction := newLLVMFunction.
	self
		mapArguments;
		createProxyValues;
		translateBasicBlocks

]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> initialize [
	super initialize.
	valueDictionary := IdentityDictionary new.
	usedNames := Set new.
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> mapArguments [

	| argumentBaseOffset llvmArgument |
	argumentBaseOffset := 0.
	self flag: 'TODO: Add support for returning structures as arguments'.
	function arguments doWithIndex: [ :arg :index |
		llvmArgument := llvmFunction arguments at: index + argumentBaseOffset.
		llvmArgument name: (self convertName: arg name).
		valueDictionary at: arg put: llvmArgument
	]
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> moduleTranslator [
	^ moduleTranslator
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> moduleTranslator: anObject [
	moduleTranslator := anObject
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> target [
	^ target
]

{ #category : #accessing }
SLVMLLVMFunctionCodeGenerator >> target: anObject [
	target := anObject
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> translateBasicBlocks [
	llvmFunction basicBlocks do: [ :bb |
		bb instructionsReplaceWith: [ :instruction | self translateProxyInstruction: instruction ]
	]
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> translateProxyInstruction: proxyInstruction [
	| original replacement |
	original := proxyInstruction sourceValue.
	replacement := original accept: self.
	replacement isCollection ifTrue: [ 
		replacement ifEmpty: [ 
			valueDictionary at: proxyInstruction sourceValue put: nil
		] ifNotEmpty: [ 
			self convertDebugLocationFrom: original into: replacement first.
			valueDictionary at: proxyInstruction sourceValue put: replacement last
		].
	] ifFalse: [
		self convertDebugLocationFrom: original into: replacement.
		valueDictionary at: proxyInstruction sourceValue put: replacement
	].

	^ replacement
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> translateType: aType [
	^ moduleTranslator translateType: aType
]

{ #category : #'code generation' }
SLVMLLVMFunctionCodeGenerator >> translateValue: aValue [
	valueDictionary at: aValue ifPresent: [ :existent | ^ existent ].
	^ moduleTranslator translateValue: aValue
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> vector: sourceVector insertElement: element at: destIndex [
	^ LLVMInsertElementInst new
		type: sourceVector type;
		vector: sourceVector;
		element: element;
		elementIndex: (self context int32Ty constant: destIndex);
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitAlloca: instruction [
	| valueType resultType |
	valueType := self translateType: instruction valueType.
	resultType := self translateType: instruction type.
	^ LLVMAllocaInst new
		name: (self convertName: instruction name);
		type: resultType;
		valueType: valueType;
		alignment: instruction valueType alignment;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitBinaryOperation: instruction [
	| resultType |
	resultType := self translateType: instruction type.
	BinaryOperationMap at: instruction operation ifPresent: [ :mappedOperation |
		^ LLVMBinaryOperator new
			name: (self convertName: instruction name);
			operation: mappedOperation;
			type: resultType;
			left: (self translateValue: instruction left);
			right: (self translateValue: instruction right);
			yourself
	].

	BinaryIntegerComparisonOperationMap at: instruction operation ifPresent: [ :mappedOperation |
		^ LLVMICmpInst new
			name: (self convertName: instruction name);
			operation: mappedOperation;
			type: resultType;
			left: (self translateValue: instruction left);
			right: (self translateValue: instruction right);
			yourself
	].

	BinaryFloatComparisonOperationMap at: instruction operation ifPresent: [ :mappedOperation |
		^ LLVMFCmpInst new
			name: (self convertName: instruction name);
			operation: mappedOperation;
			type: resultType;
			left: (self translateValue: instruction left);
			right: (self translateValue: instruction right);
			yourself
	].

	self error: 'Unsupported binary operation.'

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitBranch: instruction [
	^ LLVMBranchInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		condition: (self translateValue: instruction condition);
		trueDestination: (self translateValue: instruction trueBlock);
		falseDestination: (self translateValue: instruction falseBlock);
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitCall: instruction [
	| type calledFunction arguments |
	type := self translateType: instruction type.
	calledFunction := self translateValue: instruction functionValue.
	arguments := instruction arguments collect: [ :arg | self translateValue: arg ].
	^ LLVMCallInst new
		name: (self convertName: instruction name);
		calledFunction: calledFunction;
		arguments: arguments;
		type: type;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitDebugInstructionDeclareVariable: instruction [
	| debugDeclareIntrinsic address localVariable expression |
	debugDeclareIntrinsic := moduleTranslator llvmModule getDebugDeclareIntrinsic.

	address := (self translateValue: instruction variable) asLLVMMetadata asLLVMValueFor: self context.
	localVariable := (self convertDebugVariable: instruction debugInformation) asLLVMValueFor: self context.
	expression := moduleTranslator emptyDebugExpression asLLVMValueFor: self context.

	^ LLVMCallInst new
		name: (self convertName: instruction name);
		calledFunction: debugDeclareIntrinsic;
		arguments: {address . localVariable . expression };
		type: debugDeclareIntrinsic returnType;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitDebugInstructionSetVariableValue: instruction [
	| debugValueIntrinsic localVariable expression newValue offset |
	debugValueIntrinsic := moduleTranslator llvmModule getDebugValueIntrinsic.
	newValue := (self translateValue: instruction value) asLLVMMetadata asLLVMValueFor: self context.
	offset := self context int64Ty constant: 0.

	localVariable := (self convertDebugVariable: instruction variable) asLLVMValueFor: self context.
	expression := moduleTranslator emptyDebugExpression asLLVMValueFor: self context.
	
	^ LLVMCallInst new
		name: (self convertName: instruction name);
		calledFunction: debugValueIntrinsic;
		arguments: {newValue . offset . localVariable . expression };
		type: debugValueIntrinsic returnType;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitExtractValue: instruction [
	^ LLVMExtractValueInst new
		name: (self convertName: instruction name);
		type: (self translateType: instruction type);
		aggregate: (self translateValue: instruction aggregate);
		indices: instruction indices;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitExtractVectorElement: instruction [
	^ LLVMExtractElementInst new
		name: (self convertName: instruction name);
		type: (self translateType: instruction type);
		vector: (self translateValue: instruction vector);
		index: (self translateValue: instruction index);
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitFloatingPointCast: instruction [
	instruction source type size < instruction type size ifTrue: [ 
		^ LLVMFPExtInst new
			type: (self translateType: instruction type);
			name: (self convertName: instruction name);
			source: (self translateValue: instruction source);
			yourself
	].
	^ LLVMFPTruncInst new
			type: (self translateType: instruction type);
			name: (self convertName: instruction name);
			source: (self translateValue: instruction source);
			yourself

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitGetElementPointer: instruction [
	^ LLVMGetElementPtrInst new
		type: (self translateType: instruction type);
		name: (self convertName: instruction name);
		pointer: (self translateValue: instruction pointer);
		indices: (instruction indices collect: [ :index | self translateValue: index ]);
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitIntToFloatCast: instruction [
	instruction source type isSigned ifTrue: [ 
		^ LLVMSIToFPInst new
				type: (self translateType: instruction type);
				name: (self convertName: instruction name);
				source: (self translateValue: instruction source);
				yourself
	].
	^ LLVMUIToFPInst new
			type: (self translateType: instruction type);
			name: (self convertName: instruction name);
			source: (self translateValue: instruction source);
			yourself

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitJump: instruction [
	| destination |
	destination := self translateValue: instruction destination.
	^ LLVMBranchInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		trueDestination: destination;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitLoad: instruction [
	| pointer type |
	type := self translateType: instruction type.
	pointer := self translateValue: instruction variable.
	^ LLVMLoadInst new
		name: (self convertName: instruction name);
		volatile: instruction volatile;
		pointer: pointer;
		type: type;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitMakeMatrix: instruction [
	| matrixType resultInstruction destIndex |
	matrixType := self translateType: instruction type.
	resultInstruction := matrixType zeroConstant.
	destIndex := 0.
	^ Array streamContents: [ :out |
		instruction parameters do: [ :param |
			resultInstruction := self aggregate: resultInstruction
					insertValue: (self translateValue: param) at: destIndex.
				out nextPut: resultInstruction.
				destIndex := destIndex + 1.
		]
	]
	
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitMakeVector: instruction [
	| vectorType resultInstruction destIndex |
	vectorType := self translateType: instruction type.
	resultInstruction := vectorType zeroConstant.
	destIndex := 0.
	^ Array streamContents: [ :out |
		instruction parameters do: [ :param |
			param type isVectorType ifTrue: [
				self halt.
			] ifFalse: [
				resultInstruction := self vector: resultInstruction
					insertElement: (self translateValue: param) at: destIndex.
				out nextPut: resultInstruction.
				destIndex := destIndex + 1.
			]
		]
	].
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitPhi: instruction [
	| result |
	result := LLVMPHINode new
			name: (self convertName: instruction name);
		type: (self translateType: instruction type);
		yourself.
	instruction valuesAndParentsDo: [ :value :parent |
		result addValue: (self translateValue: value) incomingFrom: (self translateValue: parent)
	].

	^ result
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitReturn: instruction [
	^ LLVMReturnInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		value: (self translateValue: instruction value);
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitReturnVoid: instruction [
	^ LLVMReturnInst new
		name: (self convertName: instruction name);
		type: self context voidTy;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitStore: instruction [
	| pointer value |
	pointer := self translateValue: instruction variable.
	value := self translateValue: instruction value.
	^ LLVMStoreInst new
		name: (self convertName: instruction name);
		volatile: instruction volatile;
		pointer: pointer;
		value: value;
		type: self context voidTy;
		yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnaryFloatNegation: instruction [
	| resultType |
	resultType := self translateType: instruction type.
	self assert: resultType isFloatingPointTy.
	^ LLVMBinaryOperator new
			name: (self convertName: instruction name);
			operation: #fsub;
			type: resultType;
			left: resultType zeroConstant;
			right: (self translateValue: instruction operand);
			yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnaryLogicalNot: instruction [
	instruction operand type isBooleanType ifTrue: [ ^ self visitUnaryNot: instruction ].
	^ self halt
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnaryNegation: instruction [
	| resultType |
	resultType := self translateType: instruction type.
	self assert: resultType isIntegerTy.
	^ LLVMBinaryOperator new
			name: (self convertName: instruction name);
			operation: #sub;
			type: resultType;
			left: resultType zeroConstant;
			right: (self translateValue: instruction operand);
			yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnaryNot: instruction [
	| resultType |
	resultType := self translateType: instruction type.
	self assert: resultType isIntegerTy.
	^ LLVMBinaryOperator new
			name: (self convertName: instruction name);
			operation: #xor;
			type: resultType;
			left: resultType allOnesConstant;
			right: (self translateValue: instruction operand);
			yourself
]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnaryOperation: instruction [
	^ self perform: (UnaryOperationMap at: instruction operation) with: instruction

]

{ #category : #visiting }
SLVMLLVMFunctionCodeGenerator >> visitUnarySqrt: instruction [
	self halt

]

"
I generate Pharo CompiledMethods that use Lowcode.
"
Class {
	#name : #SLVMPharoLowcodeFunctionCodeGenerator,
	#superclass : #SLVMPharoFunctionCodeGenerator,
	#instVars : [
		'localFrameInstruction',
		'lowcodeUsed'
	],
	#classVars : [
		'BinaryOperationImplementation'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #initialization }
SLVMPharoLowcodeFunctionCodeGenerator class >> initialize [
	BinaryOperationImplementation := Dictionary newFromPairs: #(
		add		emitAdd:
		sub   emitSubtract:
		mul   emitMultiply:
		div   emitDivide:
		udiv  emitUnsignedDivide:
		rem   emitRemainder:
		urem  emitUnsignedRemainder:

		bitand emitBitAnd:
		bitor emitBitOr:
		bitxor emitBitXor:

		shiftleft emitShiftLeft:
		shiftright emitShiftRight:
		shiftrightarithmetic emitShiftRightArithmetic:
		rotateleft emitRotateLeft:
		rotateright emitRotateRight:

		ilt emitSignedLessThan:
		ile emitSignedLessOrEqual:
		ieq emitIntegerEqual:
		ine emitIntegerNotEqual:
		igt emitSignedGreaterThan:
		ige emitSignedGreaterOrEqual:

		ult emitUnsignedLessThan:
		ule emitUnsignedLessOrEqual:
		ugt emitUnsignedGreaterThan:
		uge emitUnsignedGreaterOrEqual:

		fadd 		emitFloatAdd:
		fsub 		emitFloatSubtract:
		fmul 		emitFloatMultiply:
		fdiv 		emitFloatDivide:
		frem 		emitFloatRemainder:

		uflt emitFloatUnorderedLessThan:
		ufle emitFloatUnorderedLessOrEqual:
		ufeq emitFloatUnorderedEqual:
		ufne emitFloatUnorderedNotEqual:
		ufgt emitFloatUnorderedGreaterThan:
		ufge emitFloatUnorderedGreaterOrEqual:

		oflt emitFloatOrderedLessThan:
		ofle emitFloatOrderedLessOrEqual:
		ofeq emitFloatOrderedEqual:
		ofne emitFloatOrderedNotEqual:
		ofgt emitFloatOrderedGreaterThan:
		ofge emitFloatOrderedGreaterOrEqual:
		
		dynObjectIdentityEquals emitObjectIdentityEqual:
		dynObjectIdentityNotEquals emitObjectIdentityNotEqual:
		
		mulMatrixMatrix emitMultiplyMatrixWithMatrix:
		mulMatrixVector emitMultiplyMatrixWithVector:
		mulVectorMatrix emitMultiplyVectorWithMatrix:
	)
]

{ #category : #adding }
SLVMPharoLowcodeFunctionCodeGenerator >> add: anInstruction [
	super add: anInstruction.
	anInstruction isLowcodeInstruction ifTrue: [
		lowcodeUsed := true
	]
]

{ #category : #'code generation' }
SLVMPharoLowcodeFunctionCodeGenerator >> allocateTemporarySize: size alignment: alignment [
	| offset |
	offset := localFrameInstruction extendA alignedTo: alignment.
	localFrameInstruction extendA: offset + size.
	^ offset
]

{ #category : #'code generation' }
SLVMPharoLowcodeFunctionCodeGenerator >> convertBooleanValueToOop: value [
	value type isBooleanType ifTrue: [
		self lowcodeBoolean32ToOop
	].
]

{ #category : #'code generation' }
SLVMPharoLowcodeFunctionCodeGenerator >> createArgumentTemporary: rawName type: type [
	type isDynamicObjectPointerType ifTrue: [ ^ self createObjectTemporary: rawName type: type ].
	self halt
]

{ #category : #'code generation' }
SLVMPharoLowcodeFunctionCodeGenerator >> createBasicBlocksAndTemporaries [
	self
		createObjectTemporary: #__lowcodeContextMark__;
		createObjectTemporary: #__lowcodePreviousNativeStackPointer__;
		createObjectTemporary: #__lowcodeNativeFramePointer__;
		createObjectTemporary: #__lowcodeNativeStackPointer__;
		createObjectTemporary: #__lowcodeCalloutState__.
	 super createBasicBlocksAndTemporaries
]

{ #category : #'code generation' }
SLVMPharoLowcodeFunctionCodeGenerator >> createPrelude [
	"Make sure this is always this special instruction."
	localFrameInstruction := IRInstruction lowcodeInstruction: 1126 extendA: 0.
	super createPrelude.
]

{ #category : #'code generation' }
SLVMPharoLowcodeFunctionCodeGenerator >> createTemporary: rawName type: type [
	| location |
	type isDynamicObjectPointerType ifTrue: [ ^ super createTemporary: rawName type: type ].
	location := self allocateTemporarySize: type size alignment: type alignment.
	^ SLVMPharoFunctionLocal new name: rawName; type: type; location: location; yourself.
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitAdd: binary [
	| type |
	self assert: binary left type = binary right type.
	self assert: binary type isIntegerType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	type := binary left type.
	type size <= 4 ifTrue: [ 
		self lowcodeAdd32
	] ifFalse: [
		self assert: type size = 8.
		self lowcodeAdd64
	]
]

{ #category : #'code generation' }
SLVMPharoLowcodeFunctionCodeGenerator >> emitBasicBlockPrelude: basicBlock [
	basicBlock index = 1 ifTrue: [
		self add: localFrameInstruction.
		lowcodeUsed := false
	].
	super emitBasicBlockPrelude: basicBlock
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitDivide: binary [
	| type |
	self assert: binary left type = binary right type.
	self assert: binary type isIntegerType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	type := binary left type.
	type size <= 4 ifTrue: [ 
		self lowcodeDiv32
	] ifFalse: [
		self assert: type size = 8.
		self lowcodeDiv64
	]
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitFloatAdd: binary [
	| type |
	self assert: binary left type = binary right type.
	self assert: binary type isFloatType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	type := binary left type.
	type size = 4 ifTrue: [ 
		self lowcodeFloat32Add
	] ifFalse: [
		self assert: type size = 8.
		self lowcodeFloat64Add
	]
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitFloatDivide: binary [
	| type |
	self assert: binary left type = binary right type.
	self assert: binary type isFloatType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	type := binary left type.
	type size = 4 ifTrue: [ 
		self lowcodeFloat32Div
	] ifFalse: [
		self assert: type size = 8.
		self lowcodeFloat64Div
	]
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitFloatMultiply: binary [
	| type |
	self assert: binary left type = binary right type.
	self assert: binary type isFloatType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	type := binary left type.
	type size = 4 ifTrue: [ 
		self lowcodeFloat32Mul
	] ifFalse: [
		self assert: type size = 8.
		self lowcodeFloat64Mul
	]
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitFloatSubtract: binary [
	| type |
	self assert: binary left type = binary right type.
	self assert: binary type isFloatType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	type := binary left type.
	type size = 4 ifTrue: [ 
		self lowcodeFloat32Sub
	] ifFalse: [
		self assert: type size = 8.
		self lowcodeFloat64Sub
	]
]

{ #category : #variables }
SLVMPharoLowcodeFunctionCodeGenerator >> emitGetElementPointerOffsets: instruction [
	| indicesWithStrides constantDisplacement rawIndicesWithStrides |
	constantDisplacement := 0.
	indicesWithStrides := OrderedCollection new.
	rawIndicesWithStrides := instruction indicesWithStrides.
	
	rawIndicesWithStrides do: [ :indexStrideOffset |
		indexStrideOffset second ~= 0 ifTrue: [ 
			indicesWithStrides add: { indexStrideOffset first . indexStrideOffset second }
		].
	
		constantDisplacement := constantDisplacement + indexStrideOffset third.
	].

	constantDisplacement ~= 0 ifTrue: [
		self lowcodePointerAddConstantOffset: constantDisplacement
	].

	indicesWithStrides do: [ :pair |
		pair first type size <= 4 ifTrue: [ 
			self
				visitExpression: pair first;
				lowcodePushConstantUInt32: pair second;
				lowcodeMul32;
				lowcodeAdd32
		] ifFalse: [
			self assert: pair first type size = 8.
			self
				visitExpression: pair first;
				lowcodePushConstantUInt64: pair second;
				lowcodePushZero64;
				lowcodeMul64;
				lowcodeAdd64
		].
	].

]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitIntegerEqual: binary [
	| type |
	self assert: binary left type = binary right type.
	self assert: binary left type isIntegerType.
	self assert: binary type isBooleanType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	type := binary left type.
	type size <= 4 ifTrue: [ 
		self lowcodeInt32Equal
	] ifFalse: [
		self assert: type size = 8.
		self lowcodeInt64Equal
	]
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitIntegerNotEqual: binary [
	| type |
	self assert: binary left type = binary right type.
	self assert: binary left type isIntegerType.
	self assert: binary type isBooleanType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	type := binary left type.
	type size <= 4 ifTrue: [ 
		self lowcodeInt32NotEqual
	] ifFalse: [
		self assert: type size = 8.
		self lowcodeInt64NotEqual
	]
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitMultiply: binary [
	| type |
	self assert: binary left type = binary right type.
	self assert: binary type isIntegerType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	type := binary left type.
	type size <= 4 ifTrue: [ 
		self lowcodeMul32
	] ifFalse: [
		self assert: type size = 8.
		self lowcodeMul64
	]
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitObjectBinaryExpression: binary [
	self assert: binary left type = binary right type.
	self assert: binary left type isDynamicObjectPointerType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	self send: (BinaryOperationMessageMap at: binary operation).
	binary type isBooleanType ifTrue: [
		self lowcodeOopToBoolean32
	]
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitObjectIdentityEqual: binary [
	^ self emitObjectBinaryExpression: binary
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitObjectIdentityNotEqual: binary [
	^ self emitObjectBinaryExpression: binary
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitSubtract: binary [
	| type |
	self assert: binary left type = binary right type.
	self assert: binary type isIntegerType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	type := binary left type.
	type size <= 4 ifTrue: [ 
		self lowcodeSub32
	] ifFalse: [
		self assert: type size = 8.
		self lowcodeSub64
	]
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitUnsignedGreaterOrEqual: binary [
	| type |
	self assert: binary left type = binary right type.
	self assert: binary left type isIntegerType.
	self assert: binary type isBooleanType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	type := binary left type.
	type size <= 4 ifTrue: [ 
		self lowcodeUint32GreatEqual
	] ifFalse: [
		self assert: type size = 8.
		self lowcodeUint64GreatEqual
	]
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitUnsignedGreaterThan: binary [
	| type |
	self assert: binary left type = binary right type.
	self assert: binary left type isIntegerType.
	self assert: binary type isBooleanType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	type := binary left type.
	type size <= 4 ifTrue: [ 
		self lowcodeUint32Great
	] ifFalse: [
		self assert: type size = 8.
		self lowcodeUint64Great
	]
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitUnsignedLessOrEqual: binary [
	| type |
	self assert: binary left type = binary right type.
	self assert: binary left type isIntegerType.
	self assert: binary type isBooleanType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	type := binary left type.
	type size <= 4 ifTrue: [ 
		self lowcodeUint32LessEqual
	] ifFalse: [
		self assert: type size = 8.
		self lowcodeUint64LessEqual
	]
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> emitUnsignedLessThan: binary [
	| type |
	self assert: binary left type = binary right type.
	self assert: binary left type isIntegerType.
	self assert: binary type isBooleanType.
	self visitExpression: binary left.
	self visitExpression: binary right.
	type := binary left type.
	type size <= 4 ifTrue: [ 
		self lowcodeUint32Less
	] ifFalse: [
		self assert: type size = 8.
		self lowcodeUint64Less
	]
]

{ #category : #initialization }
SLVMPharoLowcodeFunctionCodeGenerator >> initialize [
	super initialize.
	lowcodeUsed := false.
]

{ #category : #operations }
SLVMPharoLowcodeFunctionCodeGenerator >> isObjectBinaryExpression: binaryExpression [
	^ binaryExpression left type isDynamicObjectPointerType
]

{ #category : #variables }
SLVMPharoLowcodeFunctionCodeGenerator >> loadValueFromPointer: anInstruction [
	self visitExpression: anInstruction variable.
	anInstruction value type pushFromMemoryUsingLowcodeWith: self.

]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeAdd32 [
	self add: (IRInstruction lowcodeInstruction: 1000)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeAdd64 [
	self add: (IRInstruction lowcodeInstruction: 1001)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeAlloca32 [
	self add: (IRInstruction lowcodeInstruction: 1002)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeAlloca64 [
	self add: (IRInstruction lowcodeInstruction: 1003)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeAnd32 [
	self add: (IRInstruction lowcodeInstruction: 1004)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeAnd64 [
	self add: (IRInstruction lowcodeInstruction: 1005)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeArithmeticRightShift32 [
	self add: (IRInstruction lowcodeInstruction: 1006)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeArithmeticRightShift64 [
	self add: (IRInstruction lowcodeInstruction: 1007)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeBeginCall: a1Nalignment [
	self add: (IRInstruction lowcodeInstruction: 1008 extendA: a1Nalignment)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeBoolean32ToOop [
	self add: (IRInstruction lowcodeInstruction: 0)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeBoolean64ToOop [
	self add: (IRInstruction lowcodeInstruction: 1)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeByteSizeOf [
	self add: (IRInstruction lowcodeInstruction: 2000)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeCallArgumentFloat32 [
	self add: (IRInstruction lowcodeInstruction: 1009)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeCallArgumentFloat64 [
	self add: (IRInstruction lowcodeInstruction: 1010)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeCallArgumentInt32 [
	self add: (IRInstruction lowcodeInstruction: 1011)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeCallArgumentInt64 [
	self add: (IRInstruction lowcodeInstruction: 1012)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeCallArgumentPointer [
	self add: (IRInstruction lowcodeInstruction: 1013)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeCallArgumentSpace: a1NspaceSize [
	self add: (IRInstruction lowcodeInstruction: 1014 extendA: a1NspaceSize)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeCallArgumentStructure: a1NstructureSize [
	self add: (IRInstruction lowcodeInstruction: 1015 extendA: a1NstructureSize)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeCallInstruction: a1Nfunction [
	self add: (IRInstruction lowcodeInstruction: 1016 extendA: a1Nfunction)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeCallPhysical: a1NregisterID [
	self add: (IRInstruction lowcodeInstruction: 1017 extendA: a1NregisterID)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeCheckSessionIdentifier: a1NexpectedSession [
	self add: (IRInstruction lowcodeInstruction: 1018 extendA: a1NexpectedSession)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeCompareAndSwap32 [
	self add: (IRInstruction lowcodeInstruction: 1019)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeDiv32 [
	self add: (IRInstruction lowcodeInstruction: 1020)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeDiv64 [
	self add: (IRInstruction lowcodeInstruction: 1021)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeDuplicateFloat32 [
	self add: (IRInstruction lowcodeInstruction: 1022)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeDuplicateFloat64 [
	self add: (IRInstruction lowcodeInstruction: 1023)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeDuplicateInt32 [
	self add: (IRInstruction lowcodeInstruction: 1024)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeDuplicateInt64 [
	self add: (IRInstruction lowcodeInstruction: 1025)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeDuplicatePointer [
	self add: (IRInstruction lowcodeInstruction: 1026)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeEffectiveAddress32 [
	self add: (IRInstruction lowcodeInstruction: 1027)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeEffectiveAddress64 [
	self add: (IRInstruction lowcodeInstruction: 1028)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeEndCall [
	self add: (IRInstruction lowcodeInstruction: 1029)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeEndCallNoCleanup [
	self add: (IRInstruction lowcodeInstruction: 1030)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFirstFieldPointer [
	self add: (IRInstruction lowcodeInstruction: 2001)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFirstIndexableFieldPointer [
	self add: (IRInstruction lowcodeInstruction: 2002)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32Add [
	self add: (IRInstruction lowcodeInstruction: 1031)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32Div [
	self add: (IRInstruction lowcodeInstruction: 1032)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32Equal [
	self add: (IRInstruction lowcodeInstruction: 1033)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32Great [
	self add: (IRInstruction lowcodeInstruction: 1034)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32GreatEqual [
	self add: (IRInstruction lowcodeInstruction: 1035)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32Less [
	self add: (IRInstruction lowcodeInstruction: 1036)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32LessEqual [
	self add: (IRInstruction lowcodeInstruction: 1037)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32Mul [
	self add: (IRInstruction lowcodeInstruction: 1038)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32Neg [
	self add: (IRInstruction lowcodeInstruction: 1039)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32NotEqual [
	self add: (IRInstruction lowcodeInstruction: 1040)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32Sqrt [
	self add: (IRInstruction lowcodeInstruction: 1041)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32Sub [
	self add: (IRInstruction lowcodeInstruction: 1042)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32ToFloat64 [
	self add: (IRInstruction lowcodeInstruction: 1043)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32ToInt32 [
	self add: (IRInstruction lowcodeInstruction: 1044)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32ToInt64 [
	self add: (IRInstruction lowcodeInstruction: 1045)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32ToOop [
	self add: (IRInstruction lowcodeInstruction: 2)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32ToUInt32 [
	self add: (IRInstruction lowcodeInstruction: 1046)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat32ToUInt64 [
	self add: (IRInstruction lowcodeInstruction: 1047)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64Add [
	self add: (IRInstruction lowcodeInstruction: 1048)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64Div [
	self add: (IRInstruction lowcodeInstruction: 1049)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64Equal [
	self add: (IRInstruction lowcodeInstruction: 1050)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64Great [
	self add: (IRInstruction lowcodeInstruction: 1051)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64GreatEqual [
	self add: (IRInstruction lowcodeInstruction: 1052)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64Less [
	self add: (IRInstruction lowcodeInstruction: 1053)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64LessEqual [
	self add: (IRInstruction lowcodeInstruction: 1054)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64Mul [
	self add: (IRInstruction lowcodeInstruction: 1055)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64Neg [
	self add: (IRInstruction lowcodeInstruction: 1056)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64NotEqual [
	self add: (IRInstruction lowcodeInstruction: 1057)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64Sqrt [
	self add: (IRInstruction lowcodeInstruction: 1058)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64Sub [
	self add: (IRInstruction lowcodeInstruction: 1059)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64ToFloat32 [
	self add: (IRInstruction lowcodeInstruction: 1060)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64ToInt32 [
	self add: (IRInstruction lowcodeInstruction: 1061)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64ToInt64 [
	self add: (IRInstruction lowcodeInstruction: 1062)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64ToOop [
	self add: (IRInstruction lowcodeInstruction: 3)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64ToUInt32 [
	self add: (IRInstruction lowcodeInstruction: 1063)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFloat64ToUInt64 [
	self add: (IRInstruction lowcodeInstruction: 1064)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeFree [
	self add: (IRInstruction lowcodeInstruction: 1065)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInstantiateIndexable32Oop [
	self add: (IRInstruction lowcodeInstruction: 1066)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInstantiateIndexableOop: a1NindexableSize [
	self add: (IRInstruction lowcodeInstruction: 1067 extendA: a1NindexableSize)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInstantiateOop [
	self add: (IRInstruction lowcodeInstruction: 1068)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt32Equal [
	self add: (IRInstruction lowcodeInstruction: 1069)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt32Great [
	self add: (IRInstruction lowcodeInstruction: 1070)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt32GreatEqual [
	self add: (IRInstruction lowcodeInstruction: 1071)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt32Less [
	self add: (IRInstruction lowcodeInstruction: 1072)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt32LessEqual [
	self add: (IRInstruction lowcodeInstruction: 1073)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt32NotEqual [
	self add: (IRInstruction lowcodeInstruction: 1074)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt32ToFloat32 [
	self add: (IRInstruction lowcodeInstruction: 1075)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt32ToFloat64 [
	self add: (IRInstruction lowcodeInstruction: 1076)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt32ToOop [
	self add: (IRInstruction lowcodeInstruction: 4)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt32ToPointer [
	self add: (IRInstruction lowcodeInstruction: 1077)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt64Equal [
	self add: (IRInstruction lowcodeInstruction: 1078)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt64Great [
	self add: (IRInstruction lowcodeInstruction: 1079)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt64GreatEqual [
	self add: (IRInstruction lowcodeInstruction: 1080)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt64Less [
	self add: (IRInstruction lowcodeInstruction: 1081)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt64LessEqual [
	self add: (IRInstruction lowcodeInstruction: 1082)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt64NotEqual [
	self add: (IRInstruction lowcodeInstruction: 1083)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt64ToFloat32 [
	self add: (IRInstruction lowcodeInstruction: 1084)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt64ToFloat64 [
	self add: (IRInstruction lowcodeInstruction: 1085)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt64ToOop [
	self add: (IRInstruction lowcodeInstruction: 5)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeInt64ToPointer [
	self add: (IRInstruction lowcodeInstruction: 1086)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeIsBytes [
	self add: (IRInstruction lowcodeInstruction: 2003)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeIsFloatObject [
	self add: (IRInstruction lowcodeInstruction: 2004)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeIsIndexable [
	self add: (IRInstruction lowcodeInstruction: 2005)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeIsIntegerObject [
	self add: (IRInstruction lowcodeInstruction: 2006)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeIsPointers [
	self add: (IRInstruction lowcodeInstruction: 2007)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeIsWords [
	self add: (IRInstruction lowcodeInstruction: 2008)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeIsWordsOrBytes [
	self add: (IRInstruction lowcodeInstruction: 2009)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLeftShift32 [
	self add: (IRInstruction lowcodeInstruction: 1087)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLeftShift64 [
	self add: (IRInstruction lowcodeInstruction: 1088)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadArgumentAddress: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1089 nativeArgument: a1NbaseOffset)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadArgumentFloat32: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1090 nativeArgument: a1NbaseOffset)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadArgumentFloat64: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1091 nativeArgument: a1NbaseOffset)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadArgumentInt16: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1092 nativeArgument: a1NbaseOffset)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadArgumentInt32: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1093 nativeArgument: a1NbaseOffset)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadArgumentInt64: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1094 nativeArgument: a1NbaseOffset)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadArgumentInt8: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1095 nativeArgument: a1NbaseOffset)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadArgumentPointer: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1096 nativeArgument: a1NbaseOffset)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadArgumentUInt16: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1097 nativeArgument: a1NbaseOffset)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadArgumentUInt32: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1098 nativeArgument: a1NbaseOffset)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadArgumentUInt64: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1099 nativeArgument: a1NbaseOffset)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadArgumentUInt8: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1100 nativeArgument: a1NbaseOffset)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadFloat32FromMemory [
	self add: (IRInstruction lowcodeInstruction: 1101)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadFloat64FromMemory [
	self add: (IRInstruction lowcodeInstruction: 1102)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadInt16FromMemory [
	self add: (IRInstruction lowcodeInstruction: 1103)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadInt32FromMemory [
	self add: (IRInstruction lowcodeInstruction: 1104)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadInt64FromMemory [
	self add: (IRInstruction lowcodeInstruction: 1105)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadInt8FromMemory [
	self add: (IRInstruction lowcodeInstruction: 1106)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadLocalAddress: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1107 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadLocalFloat32: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1108 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadLocalFloat64: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1109 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadLocalInt16: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1110 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadLocalInt32: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1111 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadLocalInt64: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1112 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadLocalInt8: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1113 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadLocalPointer: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1114 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadLocalUInt16: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1115 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadLocalUInt32: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1116 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadLocalUInt64: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1117 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadLocalUInt8: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1118 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadObjectAt [
	self add: (IRInstruction lowcodeInstruction: 1119)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadObjectField: a1NfieldIndex [
	self add: (IRInstruction lowcodeInstruction: 1120 extendA: a1NfieldIndex)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadPointerFromMemory [
	self add: (IRInstruction lowcodeInstruction: 1121)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadUInt16FromMemory [
	self add: (IRInstruction lowcodeInstruction: 1122)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadUInt32FromMemory [
	self add: (IRInstruction lowcodeInstruction: 1123)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadUInt64FromMemory [
	self add: (IRInstruction lowcodeInstruction: 1124)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLoadUInt8FromMemory [
	self add: (IRInstruction lowcodeInstruction: 1125)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLocalFrameSize: a1Nsize [
	self add: (IRInstruction lowcodeInstruction: 1126 extendA: a1Nsize)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLockRegisters [
	self add: (IRInstruction lowcodeInstruction: 1127)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeLockVM [
	self add: (IRInstruction lowcodeInstruction: 1128)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeMalloc32 [
	self add: (IRInstruction lowcodeInstruction: 1129)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeMalloc64 [
	self add: (IRInstruction lowcodeInstruction: 1130)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeMemcpy32 [
	self add: (IRInstruction lowcodeInstruction: 1131)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeMemcpy64 [
	self add: (IRInstruction lowcodeInstruction: 1132)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeMemcpyFixed: a1Nsize [
	self add: (IRInstruction lowcodeInstruction: 1133 extendA: a1Nsize)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeMoveFloat32ToPhysical: a1NregisterID [
	self add: (IRInstruction lowcodeInstruction: 1134 extendA: a1NregisterID)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeMoveFloat64ToPhysical: a1NregisterID [
	self add: (IRInstruction lowcodeInstruction: 1135 extendA: a1NregisterID)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeMoveInt32ToPhysical: a1NregisterID [
	self add: (IRInstruction lowcodeInstruction: 1136 extendA: a1NregisterID)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeMoveInt64ToPhysical: a1NregisterID [
	self add: (IRInstruction lowcodeInstruction: 1137 extendA: a1NregisterID)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeMovePointerToPhysical: a1NregisterID [
	self add: (IRInstruction lowcodeInstruction: 1138 extendA: a1NregisterID)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeMul32 [
	self add: (IRInstruction lowcodeInstruction: 1139)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeMul64 [
	self add: (IRInstruction lowcodeInstruction: 1140)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeNeg32 [
	self add: (IRInstruction lowcodeInstruction: 1141)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeNeg64 [
	self add: (IRInstruction lowcodeInstruction: 1142)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeNot32 [
	self add: (IRInstruction lowcodeInstruction: 1143)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeNot64 [
	self add: (IRInstruction lowcodeInstruction: 1144)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOopEqual [
	self add: (IRInstruction lowcodeInstruction: 3000)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOopNotEqual [
	self add: (IRInstruction lowcodeInstruction: 3001)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOopSmallIntegerToInt32 [
	self add: (IRInstruction lowcodeInstruction: 2010)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOopSmallIntegerToInt64 [
	self add: (IRInstruction lowcodeInstruction: 2011)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOopToBoolean32 [
	self add: (IRInstruction lowcodeInstruction: 2012)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOopToBoolean64 [
	self add: (IRInstruction lowcodeInstruction: 2013)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOopToFloat32 [
	self add: (IRInstruction lowcodeInstruction: 2014)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOopToFloat64 [
	self add: (IRInstruction lowcodeInstruction: 2015)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOopToInt32 [
	self add: (IRInstruction lowcodeInstruction: 2016)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOopToInt64 [
	self add: (IRInstruction lowcodeInstruction: 2017)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOopToPointer [
	self add: (IRInstruction lowcodeInstruction: 2018)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOopToPointerReinterpret [
	self add: (IRInstruction lowcodeInstruction: 2019)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOopToUInt32 [
	self add: (IRInstruction lowcodeInstruction: 2020)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOopToUInt64 [
	self add: (IRInstruction lowcodeInstruction: 2021)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOr32 [
	self add: (IRInstruction lowcodeInstruction: 1145)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeOr64 [
	self add: (IRInstruction lowcodeInstruction: 1146)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePerformCallout: a1Nfunction [
	self add: (IRInstruction lowcodeInstruction: 1147 extendA: a1Nfunction)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePerformCalloutIndirect [
	self add: (IRInstruction lowcodeInstruction: 1148)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePin [
	self add: (IRInstruction lowcodeInstruction: 2022)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePlaftormCode [
	self add: (IRInstruction lowcodeInstruction: 1161)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePointerAddConstantOffset: a1Noffset [
	self add: (IRInstruction lowcodeInstruction: 1162 extendB: a1Noffset)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePointerAddOffset32 [
	self add: (IRInstruction lowcodeInstruction: 1163)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePointerAddOffset64 [
	self add: (IRInstruction lowcodeInstruction: 1164)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePointerEqual [
	self add: (IRInstruction lowcodeInstruction: 1165)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePointerNotEqual [
	self add: (IRInstruction lowcodeInstruction: 1166)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePointerToInt32 [
	self add: (IRInstruction lowcodeInstruction: 1167)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePointerToInt64 [
	self add: (IRInstruction lowcodeInstruction: 1168)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePointerToOop: a1NpointerClassLiteral [
	self add: (IRInstruction lowcodeInstruction: 6 literal: a1NpointerClassLiteral)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePointerToOopReinterprer [
	self add: (IRInstruction lowcodeInstruction: 7)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePopFloat32 [
	self add: (IRInstruction lowcodeInstruction: 1169)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePopFloat64 [
	self add: (IRInstruction lowcodeInstruction: 1170)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePopInt32 [
	self add: (IRInstruction lowcodeInstruction: 1171)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePopInt64 [
	self add: (IRInstruction lowcodeInstruction: 1172)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePopMultipleNative: a1NpopSize [
	self add: (IRInstruction lowcodeInstruction: 1173 extendA: a1NpopSize)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePopPointer [
	self add: (IRInstruction lowcodeInstruction: 1174)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushCalloutResultFloat32 [
	self add: (IRInstruction lowcodeInstruction: 1149)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushCalloutResultFloat64 [
	self add: (IRInstruction lowcodeInstruction: 1150)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushCalloutResultInt32 [
	self add: (IRInstruction lowcodeInstruction: 1151)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushCalloutResultInt64 [
	self add: (IRInstruction lowcodeInstruction: 1152)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushCalloutResultPointer [
	self add: (IRInstruction lowcodeInstruction: 1153)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushConstantUInt32: a1Nconstant [
	self add: (IRInstruction lowcodeInstruction: 1175 extendA: a1Nconstant)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushConstantUInt64: a1Nconstant [
	self add: (IRInstruction lowcodeInstruction: 1176 extendA: a1Nconstant)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushNullPointer [
	self add: (IRInstruction lowcodeInstruction: 1177)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushOne32 [
	self add: (IRInstruction lowcodeInstruction: 1178)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushOne64 [
	self add: (IRInstruction lowcodeInstruction: 1179)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushOneFloat32 [
	self add: (IRInstruction lowcodeInstruction: 1180)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushOneFloat64 [
	self add: (IRInstruction lowcodeInstruction: 1181)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushPhysicalFloat32: a1NregisterID [
	self add: (IRInstruction lowcodeInstruction: 1182 extendA: a1NregisterID)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushPhysicalFloat64: a1NregisterID [
	self add: (IRInstruction lowcodeInstruction: 1183 extendA: a1NregisterID)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushPhysicalInt32: a1NregisterID [
	self add: (IRInstruction lowcodeInstruction: 1184 extendA: a1NregisterID)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushPhysicalInt64: a1NregisterID [
	self add: (IRInstruction lowcodeInstruction: 1185 extendA: a1NregisterID)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushPhysicalPointer: a1NregisterID [
	self add: (IRInstruction lowcodeInstruction: 1186 extendA: a1NregisterID)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushSessionIdentifier [
	self add: (IRInstruction lowcodeInstruction: 1187)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushZero32 [
	self add: (IRInstruction lowcodeInstruction: 1188)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushZero64 [
	self add: (IRInstruction lowcodeInstruction: 1189)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushZeroFloat32 [
	self add: (IRInstruction lowcodeInstruction: 1190)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodePushZeroFloat64 [
	self add: (IRInstruction lowcodeInstruction: 1191)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeRem32 [
	self add: (IRInstruction lowcodeInstruction: 1192)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeRem64 [
	self add: (IRInstruction lowcodeInstruction: 1193)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeRightShift32 [
	self add: (IRInstruction lowcodeInstruction: 1194)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeRightShift64 [
	self add: (IRInstruction lowcodeInstruction: 1195)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeSignExtend32From16 [
	self add: (IRInstruction lowcodeInstruction: 1196)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeSignExtend32From8 [
	self add: (IRInstruction lowcodeInstruction: 1197)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeSignExtend64From16 [
	self add: (IRInstruction lowcodeInstruction: 1198)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeSignExtend64From32 [
	self add: (IRInstruction lowcodeInstruction: 1199)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeSignExtend64From8 [
	self add: (IRInstruction lowcodeInstruction: 1200)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeSmallInt32ToOop [
	self add: (IRInstruction lowcodeInstruction: 8)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreFloat32ToMemory [
	self add: (IRInstruction lowcodeInstruction: 1201)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreFloat64ToMemory [
	self add: (IRInstruction lowcodeInstruction: 1202)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreInt16ToMemory [
	self add: (IRInstruction lowcodeInstruction: 1203)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreInt32ToMemory [
	self add: (IRInstruction lowcodeInstruction: 1204)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreInt64ToMemory [
	self add: (IRInstruction lowcodeInstruction: 1205)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreInt8ToMemory [
	self add: (IRInstruction lowcodeInstruction: 1206)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreLocalFloat32: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1207 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreLocalFloat64: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1208 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreLocalInt16: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1209 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreLocalInt32: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1210 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreLocalInt64: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1211 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreLocalInt8: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1212 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreLocalPointer: a1NbaseOffset [
	self add: (IRInstruction lowcodeInstruction: 1213 extendA: (self nativeLocalOffsetOf: a1NbaseOffset))
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreObjectField: a1NfieldIndex [
	self add: (IRInstruction lowcodeInstruction: 3002 extendA: a1NfieldIndex)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStoreObjectFieldAt [
	self add: (IRInstruction lowcodeInstruction: 3003)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeStorePointerToMemory [
	self add: (IRInstruction lowcodeInstruction: 1214)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeSub32 [
	self add: (IRInstruction lowcodeInstruction: 1215)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeSub64 [
	self add: (IRInstruction lowcodeInstruction: 1216)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeTruncate32To16 [
	self add: (IRInstruction lowcodeInstruction: 1217)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeTruncate32To8 [
	self add: (IRInstruction lowcodeInstruction: 1218)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeTruncate64To16 [
	self add: (IRInstruction lowcodeInstruction: 1219)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeTruncate64To32 [
	self add: (IRInstruction lowcodeInstruction: 1220)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeTruncate64To8 [
	self add: (IRInstruction lowcodeInstruction: 1221)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUdiv32 [
	self add: (IRInstruction lowcodeInstruction: 1222)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUdiv64 [
	self add: (IRInstruction lowcodeInstruction: 1223)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUint32Great [
	self add: (IRInstruction lowcodeInstruction: 1224)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUint32GreatEqual [
	self add: (IRInstruction lowcodeInstruction: 1225)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUint32Less [
	self add: (IRInstruction lowcodeInstruction: 1226)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUint32LessEqual [
	self add: (IRInstruction lowcodeInstruction: 1227)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUint32ToFloat32 [
	self add: (IRInstruction lowcodeInstruction: 1228)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUint32ToFloat64 [
	self add: (IRInstruction lowcodeInstruction: 1229)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUint32ToOop [
	self add: (IRInstruction lowcodeInstruction: 9)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUint64Great [
	self add: (IRInstruction lowcodeInstruction: 1230)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUint64GreatEqual [
	self add: (IRInstruction lowcodeInstruction: 1231)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUint64Less [
	self add: (IRInstruction lowcodeInstruction: 1232)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUint64LessEqual [
	self add: (IRInstruction lowcodeInstruction: 1233)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUint64ToFloat32 [
	self add: (IRInstruction lowcodeInstruction: 1234)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUint64ToFloat64 [
	self add: (IRInstruction lowcodeInstruction: 1235)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUint64ToOop [
	self add: (IRInstruction lowcodeInstruction: 10)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUmul32 [
	self add: (IRInstruction lowcodeInstruction: 1236)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUmul64 [
	self add: (IRInstruction lowcodeInstruction: 1237)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUnlockRegisters [
	self add: (IRInstruction lowcodeInstruction: 1238)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUnlockVM [
	self add: (IRInstruction lowcodeInstruction: 1239)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUnpin [
	self add: (IRInstruction lowcodeInstruction: 2023)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUrem32 [
	self add: (IRInstruction lowcodeInstruction: 1240)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeUrem64 [
	self add: (IRInstruction lowcodeInstruction: 1241)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeXor32 [
	self add: (IRInstruction lowcodeInstruction: 1242)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeXor64 [
	self add: (IRInstruction lowcodeInstruction: 1243)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeZeroExtend32From16 [
	self add: (IRInstruction lowcodeInstruction: 1244)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeZeroExtend32From8 [
	self add: (IRInstruction lowcodeInstruction: 1245)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeZeroExtend64From16 [
	self add: (IRInstruction lowcodeInstruction: 1246)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeZeroExtend64From32 [
	self add: (IRInstruction lowcodeInstruction: 1247)
]

{ #category : #'lowcode instructions' }
SLVMPharoLowcodeFunctionCodeGenerator >> lowcodeZeroExtend64From8 [
	self add: (IRInstruction lowcodeInstruction: 1248)
]

{ #category : #'code generation' }
SLVMPharoLowcodeFunctionCodeGenerator >> nativeLocalOffsetOf: localVariableLocation [
	^ localVariableLocation
]

{ #category : #instructions }
SLVMPharoLowcodeFunctionCodeGenerator >> popTopOfType: type [
	type popTopUsingLowcodeWith: self
]

{ #category : #'code generation' }
SLVMPharoLowcodeFunctionCodeGenerator >> postProcessTranslation [
	super postProcessTranslation.
	(localFrameInstruction extendA = 0 and: [lowcodeUsed not]) ifTrue: [
		self removeLowcodeStuff
	]
]

{ #category : #variables }
SLVMPharoLowcodeFunctionCodeGenerator >> pushVariable: aVariable [
	^ aVariable emitPushUsingLowcodeWith: self
]

{ #category : #'code generation' }
SLVMPharoLowcodeFunctionCodeGenerator >> removeLowcodeStuff [
	| lowcodeTempNames |
	localFrameInstruction sequence remove: localFrameInstruction.
	lowcodeTempNames := self currentScope tempMap keys select: [:key | key beginsWith: #__lowcode].
	lowcodeTempNames size == self currentScope tempMap size ifTrue: [
		self currentScope tempMap removeAll.
	]
]

{ #category : #'code generation' }
SLVMPharoLowcodeFunctionCodeGenerator >> setupCompiledMethod: compiledMethod [
	self flag: 'FIXME: Check whether the sista bytecode set is the primary one or not.'.
	compiledMethod setSignFlag.
	compiledMethod setFrameBit: true.
]

{ #category : #'code generation' }
SLVMPharoLowcodeFunctionCodeGenerator >> setupIRMethodCompilationContext [
	ir compilationContext encoderClass: OpalEncoderForSistaV1.
]

{ #category : #variables }
SLVMPharoLowcodeFunctionCodeGenerator >> storeAndPopStackTopIntoVariable: aVariable [
	^ aVariable emitStoreAndPopStackTopUsingLowcodeWith: self
]

{ #category : #variables }
SLVMPharoLowcodeFunctionCodeGenerator >> storeAndPopValueIntoPointer: anInstruction [
	self visitExpression: anInstruction value.
	self visitExpression: anInstruction variable.
	anInstruction value type storeAndPopStackTopIntoMemoryUsingLowcodeWith: self.
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitBinaryExpression: aBinaryExpression [
	self perform: (BinaryOperationImplementation at: aBinaryExpression operation) with: aBinaryExpression

]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitBitCast: instruction [
	| sourceType targetType |
	(instruction type isPointerType and: [ self isObjectElementPointer: instruction source ]) ifTrue: [
		self visitExpression: instruction source pointer.
		self lowcodeFirstFieldPointer.
		self emitGetElementPointerOffsets: instruction source.
		^ self
	].

	self visitExpression: instruction source.
	
	sourceType := instruction source type.
	targetType := instruction type.
	(sourceType isFloatType and: [targetType isIntegerType]) ifTrue: [
		self halt
	].
	(sourceType isIntegerType and: [targetType isFloatType]) ifTrue: [
		self halt
	].
	(sourceType isIntegerType and: [targetType isPointerType]) ifTrue: [
		self halt
	].
	(sourceType isPointerType and: [targetType isIntegerType]) ifTrue: [
		self halt
	].

]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitBoolToDynamicObjectCast: cast [
	self visitExpression: cast source.
	cast source type toOopUsingLowcodeWith: self.
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitConstantValue: aConstant [
	aConstant type pushConstant: aConstant value usingLowcodeWith: self
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitDynamicObjectToBoolCast: cast [
	self visitExpression: cast source.
	cast type fromOopUsingLowcodeWith: self.
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitDynamicObjectToFloatCast: cast [
	self visitExpression: cast source.
	cast type fromOopUsingLowcodeWith: self.
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitDynamicObjectToIntCast: cast [
	self visitExpression: cast source.
	cast type fromOopUsingLowcodeWith: self.
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitDynamicObjectToStructureCast: cast [
	self visitExpression: cast source.
	self halt
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitExtractValue: anInstruction [
	self visitExpression: anInstruction aggregate.
	self halt
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitFloatToDynamicObjectCast: cast [
	self visitExpression: cast source.
	cast source type toOopUsingLowcodeWith: self.
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitFloatToIntCast: cast [
	self visitExpression: cast source.
	cast source type toInteger: cast type usingLowcodeWith: self.
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitFloatingPointCast: cast [
	self visitExpression: cast source.
	self halt
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitInsertValue: anInstruction [
	self visitExpression: anInstruction aggregate.
	self halt
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitIntToDynamicObjectCast: cast [
	self visitExpression: cast source.
	cast source type toOopUsingLowcodeWith: self.
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitIntToFloatCast: cast [
	self visitExpression: cast source.
	cast source type toFloat: cast type usingLowcodeWith: self.
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitSignExtend: cast [
	self visitExpression: cast source.
	self halt
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitStructureToDynamicObjectCast: cast [
	self visitExpression: cast source.
	self halt
]

{ #category : #visiting }
SLVMPharoLowcodeFunctionCodeGenerator >> visitZeroExtend: cast [
	self visitExpression: cast source.
	self halt
]

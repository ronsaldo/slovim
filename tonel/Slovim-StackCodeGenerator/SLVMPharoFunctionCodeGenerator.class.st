"
I generate Pharo CompiledMethods.
"
Class {
	#name : #SLVMPharoFunctionCodeGenerator,
	#superclass : #SLVMETreeVisitor,
	#instVars : [
		'compilationTarget',
		'etreeFunction',
		'ir',
		'translatedElements',
		'basicBlockMap',
		'promotedAllocas',
		'currentSequence',
		'nullSourceLocation',
		'currentSourceLocation',
		'lastBytecodeIndex',
		'nextSequenceIndex',
		'elseSequences',
		'currentBasicBlock',
		'moduleTranslator',
		'thenSequences',
		'methodTempVectorInstruction',
		'useSecondaryBytecodeSet'
	],
	#classVars : [
		'BinaryOperationMessageMap',
		'MaxNumberOfNormalTemps',
		'UnaryOperationMessageMap'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #initialization }
SLVMPharoFunctionCodeGenerator class >> initialize [
	super initialize.
	
	MaxNumberOfNormalTemps := 40.
	
	BinaryOperationMessageMap := Dictionary newFromPairs: #(
		add		+
		sub   - 
		mul   *
		div   #'//'
		udiv  #'//'
		rem   #'\\'
		urem  #'\\'

		bitand bitAnd:
		bitor bitOr:
		bitxor bitXor:

		shiftleft #'<<'
		shiftright #'>>'
		shiftrightarithmetic #'>>'
		rotateleft bitRotateLeft:
		rotateright bitRotateRight:

		ilt #'<'
		ile #'<='
		ieq =
		ine '~='
		igt #'>'
		ige #'>='

		ult #'<'
		ule #'<='
		ugt >
		uge #'>'

		fadd 		+
		fsub 		-
		fmul 		*
		fdiv 		/
		frem 		%

		uflt #'<'
		ufle #'<='
		ufeq #'='
		ufne #'~='
		ufgt >
		ufge #'>='

		oflt #'<'
		ofle #'<='
		ofeq #=
		ofne #'~='
		ofgt #'>'
		ofge #'>='
		
		dynObjectIdentityEquals #'=='
		dynObjectIdentityNotEquals #'~~'
		
		mulMatrixMatrix *
		mulMatrixVector *
		mulVectorMatrix *
	).
	
	UnaryOperationMessageMap := Dictionary newFromPairs: #(
		neg negated
		not bitInvert
		lnot not
		
		fneg negated
		fsqrt sqrt
	).
]

{ #category : #'bytecode construction' }
SLVMPharoFunctionCodeGenerator >> add: anInstruction [
	anInstruction sourceNode: currentSourceLocation.
	anInstruction bytecodeIndex: self newBytecodeIndex.
	currentSequence add: anInstruction
]

{ #category : #accessing }
SLVMPharoFunctionCodeGenerator >> bytecodeEncoderClass [
	Smalltalk version = 'Pharo6.0' ifTrue: [ 
		^ Smalltalk globals at: (useSecondaryBytecodeSet ifTrue: [ #OpalEncoderForSistaV1 ] ifFalse: [ #OpalEncoderForV3PlusClosures ])
	].

	^ useSecondaryBytecodeSet ifTrue: [ EncoderForSistaV1 ] ifFalse: [ EncoderForV3PlusClosures ]
]

{ #category : #accessing }
SLVMPharoFunctionCodeGenerator >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMPharoFunctionCodeGenerator >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> computeAggregate: aggregateType elementOffsetWithIndices: indices [
	| offset currentType indexConstant |
	offset := 0.
	currentType := aggregateType.
	indices do: [ :index |
		indexConstant := SLVMConstant type: aggregateType value: index.
		offset := offset + (currentType offsetWithIndex: indexConstant).
		currentType := currentType typeOfMemberAt: indexConstant.
	].
	^ offset
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> convertBooleanValueToOop: value [
	"Nothing required here"
]

{ #category : #variables }
SLVMPharoFunctionCodeGenerator >> convertPointerIntoVariable: aVariableExpression [
	| binding |
	(promotedAllocas includesKey: aVariableExpression) ifTrue: [ 
		^ promotedAllocas at: aVariableExpression.
	].
	
	aVariableExpression isGlobalVariable ifTrue: [
		binding := moduleTranslator translateElement: aVariableExpression.
		^ SLVMPharoLiteralVariable new
			type: aVariableExpression type baseType;
			binding: binding
	].

	(self isObjectConstantSlotPointer: aVariableExpression) ifTrue: [
		| indicesWithStrides offset |
		offset := 0.
		aVariableExpression indicesWithStrides do: [ :indexWithStride |
			self assert: indexWithStride second = 0.
			offset := offset + indexWithStride third.
		].
		^ SLVMPharoObjectSlot new
			type: aVariableExpression type baseType;
			pointer: aVariableExpression pointer;
			slotIndex: (aVariableExpression indexAt: 2) value;
			slotOffset: offset; yourself
	].

	^ nil

]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> createArgumentTemporary: rawName type: type [
	^ self createObjectTemporary: rawName type: type
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> createArguments [
	| temp |
	ir numArgs: etreeFunction arguments size.
	etreeFunction arguments doWithIndex: [ :arg :index |
		(index = 1 and: [ arg isReceiver ]) ifTrue: [ 
			ir numArgs: etreeFunction arguments size - 1.
			temp := SLVMPharoFunctionReceiver new type: arg type.
			translatedElements at: arg put: temp
		] ifFalse: [ 
			temp := self createArgumentTemporary: arg validName type: arg type.
			translatedElements at: arg put: temp
		]
	]
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> createBasicBlockAndTemporaries: aBasicBlock [
	| sequence |
	sequence := self newSequence.
	aBasicBlock isLastBranch ifTrue: [ 
		elseSequences at: aBasicBlock put: self newSequence.
		aBasicBlock lastExpression trueBlock index <= aBasicBlock index ifTrue: [ 
			thenSequences at: aBasicBlock put: self newSequence
		].
	].

	translatedElements at: aBasicBlock put: sequence.
	basicBlockMap add: (aBasicBlock -> sequence).
	
	aBasicBlock statementsDo: [ :statement |
		self createTemporaryForStatement: statement.
	]
	
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> createBasicBlocksAndTemporaries [
	etreeFunction basicBlocks do: [ :bb |
		self createBasicBlockAndTemporaries: bb
	]
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> createObjectTemporary: rawName [
	| tempMap tempName index name |
	tempMap := self currentScope tempMap.
	name := rawName asSymbol.
	tempName := tempMap at: name ifPresent: [('<temp:' , tempMap size asString, '>') asSymbol] ifAbsent: [ name ].
	
	index := tempMap size + 1.
	tempMap at: tempName put: index.
	^ index
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> createObjectTemporary: rawName type: type [
	| tempMap tempName index name vectorName |
	methodTempVectorInstruction name ifNotNil: [
		vectorName := methodTempVectorInstruction name.
		name := (vectorName , methodTempVectorInstruction vars size asString) asSymbol.
		methodTempVectorInstruction vars add: name.
		^ SLVMPharoFunctionLocal new
			name: name;
			location: name;
			vectorName: vectorName;
			type: type;
			yourself
	].

	tempMap := self currentScope tempMap.
	name := rawName asSymbol.
	tempName := tempMap at: name ifPresent: [('<temp:' , tempMap size asString, '>') asSymbol] ifAbsent: [ name ].
	
	index := tempMap size + 1.

	"Did we exceed the max number of temps? use a temporary vector."
	index = MaxNumberOfNormalTemps ifTrue: [
		tempName := #'<mainTempVector>'.
		methodTempVectorInstruction name: tempName; vars: OrderedCollection new.
		tempMap at: tempName put: index.
		^ self createObjectTemporary: rawName type: type
	].

	tempMap at: tempName put: index.

	^ SLVMPharoFunctionLocal new
		name: name;
		location: name;
		type: type;
		yourself
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> createPrelude [
	methodTempVectorInstruction := SLVMPharoIRTempVector new
		name: nil;
		vars: nil;
		yourself..
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> createTempVectorNamed: name withVars: anArray [
	self add: (IRInstruction createTempVectorNamed: name withVars: anArray).

]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> createTemporary: rawName type: type [
	^ self createObjectTemporary: rawName type: type
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> createTemporaryForStatement: anStatement [
	anStatement type isVoidType ifTrue: [ ^ self ].
	anStatement isAllocaOnlyUsedByLoadsAndStores ifTrue: [
		promotedAllocas at: anStatement put: (self createTemporary: anStatement name type: anStatement expression valueType).
		^ self.
	].

	translatedElements at: anStatement put: (self createTemporary: anStatement name type: anStatement type).

]

{ #category : #private }
SLVMPharoFunctionCodeGenerator >> currentScope [
	^ ir
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> emitBasicBlockPrelude: aPrelude [
	methodTempVectorInstruction sequence ifNil: [ 
		self add: methodTempVectorInstruction.
	]

]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> emitGetElementPointerOffsets: instruction [
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
		self pushLiteral: constantDisplacement;
			send: #_slvm_pointerAddOffset:.
	].

	indicesWithStrides do: [ :pair |
		self
			visitExpression: pair first;
			pushLiteral: pair second;
			send: #*;
			send: #_slvm_pointerAddOffset:
	].

]

{ #category : #initialization }
SLVMPharoFunctionCodeGenerator >> initialize [
	super initialize.
	currentSourceLocation := nullSourceLocation := SLVMDebugLocation null.
	lastBytecodeIndex := 0.
	nextSequenceIndex := 0.
	useSecondaryBytecodeSet := true.
]

{ #category : #testing }
SLVMPharoFunctionCodeGenerator >> isLowcodeGenerator [
	^ false
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> isObjectConstantSlotPointer: expression [
	^ expression isGetElementPointer and:
	[ expression pointer type isDynamicObjectPointerType and:
	[ expression hasConstantIndices ] ]
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> isObjectElementPointer: expression [
	^ expression isGetElementPointer and:
	[ expression pointer type isDynamicObjectPointerType ]
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> loadValueFromPointer: anInstruction [
	self visitExpression: anInstruction variable.
	anInstruction type loadValueFromPointerWith: self
]

{ #category : #accessing }
SLVMPharoFunctionCodeGenerator >> moduleTranslator [
	^ moduleTranslator
]

{ #category : #accessing }
SLVMPharoFunctionCodeGenerator >> moduleTranslator: anObject [
	moduleTranslator := anObject
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> newBytecodeIndex [
	^ lastBytecodeIndex := lastBytecodeIndex + 1
]

{ #category : #'instance creation' }
SLVMPharoFunctionCodeGenerator >> newSequence [
	^ (IRSequence orderNumber: self newSequenceIndex) method: ir
]

{ #category : #'instance creation' }
SLVMPharoFunctionCodeGenerator >> newSequenceIndex [
	^ nextSequenceIndex := nextSequenceIndex + 1
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> popTop [
	self add: IRInstruction popTop
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> popTopOfType: aType [
	aType isVoidType ifTrue: [ ^ self ].
	self popTop
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> postProcessTranslation [
	"Removed the unused method temp vector instruction."
	methodTempVectorInstruction name ifNil: [
		methodTempVectorInstruction sequence remove: methodTempVectorInstruction.
		methodTempVectorInstruction := nil.
	]
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> pushConsArray: size [

	self add: (IRInstruction pushConsArray: size)
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> pushDup [
	self add: IRInstruction pushDup
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> pushInstVar: index [

	self add: (IRInstruction pushInstVar: index).
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> pushLiteral: object [

	self add: (IRInstruction pushLiteral: object)
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> pushLiteralVariable: object [

	self add: (IRInstruction pushLiteralVariable: object)
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> pushReceiver [

	self add: (IRInstruction pushReceiver)
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> pushRemoteTemp: name inVector: nameOfVector [

	^self add: (IRInstruction pushRemoteTemp: name inVectorAt: nameOfVector)
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> pushTemp: aSymbol [

	^ self add: (IRInstruction pushTemp: aSymbol)
]

{ #category : #variables }
SLVMPharoFunctionCodeGenerator >> pushVariable: aVariable [
	^ aVariable emitPushWith: self
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> returnTop [

	self add: IRInstruction returnTop.
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> send: selector [

	^self add: (IRInstruction send: selector)
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> setupCompiledMethod: compiledMethod [
	useSecondaryBytecodeSet ifTrue: [ 
		compiledMethod setSignFlag.
	].


]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> setupIRMethodCompilationContext [
	ir compilationContext encoderClass: self bytecodeEncoderClass.
]

{ #category : #variables }
SLVMPharoFunctionCodeGenerator >> storeAndPopStackTopIntoVariable: aVariable [
	aVariable emitStoreStackTopWith: self.
	self popTop
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> storeAndPopValueIntoPointer: anInstruction [
	self visitExpression: anInstruction value.
	self visitExpression: anInstruction variable.
	anInstruction value type storeAndPopValueIntoPointerWith: self.
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> storeInstVar: name [

	^self add: (IRInstruction storeInstVar: name).
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> storeRemoteTemp: name inVector: nameOfVector [

	^self add: (IRInstruction storeRemoteTemp: name inVectorAt: nameOfVector)
]

{ #category : #instructions }
SLVMPharoFunctionCodeGenerator >> storeTemp: aSymbol [

	^self add: (IRInstruction storeTemp: aSymbol)
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> translateBasicBlock: basicBlock into: sequence [
	currentSequence := sequence.
	currentBasicBlock := basicBlock.
	self emitBasicBlockPrelude: basicBlock.
	basicBlock statementsDo: [ :statement |
		self translateStatement: statement.
		statement expression isTerminator ifTrue: [ ^ self ].
	]
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> translateBasicBlocks [
	basicBlockMap do: [ :bb |
		self translateBasicBlock: bb key into: bb value
	]
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> translateFunction: aFunction [
	| compiledMethod trailer |
	etreeFunction := aFunction.
	ir := IRMethod new.
	self setupIRMethodCompilationContext.
	
	translatedElements := IdentityDictionary new.
	elseSequences := IdentityDictionary new.
	thenSequences := IdentityDictionary new.
	basicBlockMap := OrderedCollection new.
	promotedAllocas := IdentityDictionary new.

	self createPrelude.
	self createArguments.
	self createBasicBlocksAndTemporaries.
	ir startSequence: ((IRSequence orderNumber: 0) method:ir).
	ir startSequence add:
		(IRJump new
			destination: basicBlockMap first value;
			bytecodeIndex: self newBytecodeIndex;
			yourself).
				
	aFunction debugSourceLocation ifNotNil: [ :loc |
		currentSourceLocation := loc
	].

	self translateBasicBlocks.
	self postProcessTranslation.
	trailer := CompiledMethodTrailer empty.
	aFunction debugSourceLocation ifNotNil: [
		aFunction debugSourceLocation sourceCode ifNotNil: [:sourceCode |
			trailer sourceCode: sourceCode
		]
	].

	"etreeFunction selector = #hash ifTrue: [
		Stdio stdout nextPutAll: etreeFunction selector printString; nextPutAll: ' >> '; nextPutAll: etreeFunction classBinding printString; lf.
		etreeFunction classBinding printString = '#WMComplexF->WMComplexF' ifTrue: [ 
			self halt
		]
	]."
"
	etreeFunction selector = #initializeWithRows:columns: ifTrue: [ self halt ]."
	compiledMethod := ir optimize compiledMethodWith: trailer.
	self setupCompiledMethod: compiledMethod.

	etreeFunction classBinding ifNotNil: [ 
		compiledMethod classBinding: etreeFunction classBinding
	].
	etreeFunction selector ifNotNil: [ 
		etreeFunction selector class == AdditionalMethodState ifTrue: [ 
			etreeFunction selector method: compiledMethod.
			etreeFunction selector pragmas do: [ :pragma | pragma method: compiledMethod ]
		].
		compiledMethod literalAt: compiledMethod numLiterals - 1 put: etreeFunction selector
	].

	^ compiledMethod
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> translateStatement: statement [
	(promotedAllocas includesKey: statement) ifTrue: [ ^ self ].
	
	"Translate the expression."
	self visitExpression: statement expression.
	
	"Store or pop the result of the expression."
	statement expression isTerminator ifTrue: [ ^ self ].
	statement type isVoidType ifTrue: [ ^ self ].
	statement references ifNotEmpty: [
		self storeAndPopStackTopIntoVariable: (translatedElements at: statement)
	] ifEmpty: [
		self assert: (promotedAllocas includesKey: statement) not.
		self popTopOfType: statement type
	]

]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitAlloca: allocaExpression [
	| valueType |
	valueType := allocaExpression valueType.
	valueType behavior ifNotNil: [
		^ self
			pushLiteralVariable: valueType behavior binding;
			send: #basicNew;
			send: #asPointerToInternalObjectData
	].
	self halt
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitBinaryExpression: aBinaryExpression [
	self visitExpression: aBinaryExpression left.
	self visitExpression: aBinaryExpression right.
	
	self flag: 'Handle the modularity of integers.'.
	self send: (BinaryOperationMessageMap at: aBinaryExpression operation)
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitBitCast: instruction [
	| sourceType targetType |
	(instruction type isPointerType and: [ self isObjectElementPointer: instruction source ]) ifTrue: [ 
		self visitExpression: instruction source pointer.
		self send: #asPointerToInternalObjectData.
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
SLVMPharoFunctionCodeGenerator >> visitBoolToDynamicObjectCast: cast [
	self visitExpression: cast source
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitBranch: aBranch [
	| elseSequence thenSequence |
	self visitExpression: aBranch condition.
	self convertBooleanValueToOop: aBranch condition.
	thenSequence := thenSequences at: currentBasicBlock ifAbsent: [translatedElements at: aBranch trueBlock ].
	elseSequence := elseSequences at: currentBasicBlock .
	
	self add: (IRJumpIf new boolean: true;
		destination: thenSequence;
		otherwise: elseSequence).
	
	self withSequence: elseSequence do: [
		self add: (IRJump new destination: (translatedElements at: aBranch falseBlock))
	].

	thenSequence ~~ (translatedElements at: aBranch trueBlock) ifTrue: [ 
		self withSequence: thenSequence do: [
			self add: (IRJump new destination: (translatedElements at: aBranch trueBlock))
		].
	]

]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitCall: anInstruction [
	| arguments |
	self visitExpression: anInstruction functionValue.
	anInstruction functionValue isETreeMethod ifTrue: [ 
		arguments := anInstruction arguments.
		arguments do: [ :arg | self visitExpression: arg ].
		self pushConsArray: arguments size - 1.
		^ self send: #valueWithReceiver:arguments:	
	].

	self pushLiteral: nil.
	arguments := anInstruction arguments.
	arguments do: [ :arg | self visitExpression: arg ].
	self pushConsArray: arguments size.
	self send: #valueWithReceiver:arguments:
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitConstantStructureValue: constant [
	| value |
	value := constant evaluate.
	^ self pushLiteral: value
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitConstantValue: aConstant [
	self pushLiteral: aConstant value
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitDynamicObjectToBoolCast: cast [
	self visitExpression: cast source
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitDynamicObjectToFloatCast: cast [
	self visitExpression: cast source.
	self send: #asFloat.
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitDynamicObjectToIntCast: cast [
	self visitExpression: cast source.
	self send: #asInteger.
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitDynamicObjectToStructureCast: cast [
	self visitExpression: cast source
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitETreeStatement: anStatement [
	^ self pushVariable: (translatedElements at: anStatement)
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitExpression: anExpression [
	anExpression debugSourceLocation ifNotNil: [ :loc |
		self withDebugSourceLocation: loc do: [ 
			^ anExpression accept: self
		]
	].

	^ anExpression accept: self
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitExtractValue: anInstruction [
	| aggregateType offset |
	self visitExpression: anInstruction aggregate.
	aggregateType := anInstruction aggregate type.
	offset := self computeAggregate: aggregateType elementOffsetWithIndices: anInstruction indices.
	offset ~= 0 ifTrue: [
		self pushLiteral: offset;
			send: #_slvm_pointerAddOffset:.
	].

	anInstruction type loadValueFromPointerWith: self
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitFloatToDynamicObjectCast: cast [
	self visitExpression: cast source
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitFloatToIntCast: cast [
	self visitExpression: cast source.
	self send: #asInteger
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitFloatingPointCast: cast [
	self visitExpression: cast source.
	self flag: 'Truncate the precision when required.'.
	
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitFunction: aFunction [
	| translatedFunction |
	translatedFunction := moduleTranslator translateElement: aFunction.
	self pushLiteralVariable: translatedFunction
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitFunctionArgument: anArgument [
	self pushVariable: (translatedElements at: anArgument)
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitFunctionDynamicLiteral: aLiteralConstant [
	self pushLiteral: aLiteralConstant value
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitGetElementPointer: anInstruction [
	self assert: anInstruction type isDynamicObjectType not.

	self visitExpression: anInstruction pointer.
	self emitGetElementPointerOffsets: anInstruction.

]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitInsertValue: anInstruction [
	| offset |
	self visitExpression: anInstruction aggregate.
	anInstruction canOmitCopy ifFalse: [ 
		self send: #copy.
	].

	self pushDup.
		
	offset := self computeAggregate: anInstruction type elementOffsetWithIndices: anInstruction indices.

	offset ~= 0 ifTrue: [
		self pushLiteral: offset;
			send: #_slvm_pointerAddOffset:.
	].

	self visitExpression: anInstruction value.
	anInstruction value type storeAndPopValueWith: self
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitIntToDynamicObjectCast: cast [
	self visitExpression: cast source
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitIntToFloatCast: cast [
	self visitExpression: cast source.
	self send: #asFloat
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitJump: aBranch [
	self add: (IRJump new destination: (translatedElements at: aBranch destination))
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitLoad: anInstruction [
	| variable |
	variable := self convertPointerIntoVariable: anInstruction variable.

	variable ifNil: [ 
		^ self loadValueFromPointer: anInstruction
	].

	^ self pushVariable: variable
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitMessageSend: anInstruction [
	| selector arguments |
	self visitExpression: anInstruction receiver.
	
	selector := anInstruction selector.
	arguments := anInstruction arguments.
	(selector isFunctionDynamicLiteral and: [selector value isSymbol]) ifTrue: [
		arguments do: [ :arg |
			self visitExpression: arg
		].
		self send: selector value
	] ifFalse: [
		self visitExpression: selector.
		arguments do: [ :arg |
			self visitExpression: arg
		].
		self pushConsArray: arguments size.
		self send: #perform:withArguments:
	].

]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitReturn: anInstruction [
	self visitExpression: anInstruction value.
	anInstruction value isConstantAggregateValue ifTrue: [
		self send: #copy
	].

	anInstruction value type isVoidType ifTrue: [
		self pushReceiver
	].
	self returnTop
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitSignExtend: cast [
	self visitExpression: cast source
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitStore: anInstruction [
	| variable |
	variable := self convertPointerIntoVariable: anInstruction variable.
	variable ifNil: [ 
		^ self storeAndPopValueIntoPointer: anInstruction
	].

	variable storeAndPopValue: anInstruction value with: self
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitStructureToDynamicObjectCast: cast [
	self visitExpression: cast source
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitUnaryExpression: anUnaryExpression [
	self visitExpression: anUnaryExpression operand.
	
	self send: (UnaryOperationMessageMap at: anUnaryExpression operation)
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitUnreachable: anInstruction [
	self pushReceiver;
	 send: #_slvm_unreachable
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitZeroExtend: cast [
	self visitExpression: cast source
]

{ #category : #'as yet unclassified' }
SLVMPharoFunctionCodeGenerator >> withDebugSourceLocation: newSourceLocation do: aBlock [
	| oldSourceLocation |
	oldSourceLocation := currentSourceLocation.
	currentSourceLocation := newSourceLocation.
	aBlock ensure: [ currentSourceLocation := oldSourceLocation ]
]

{ #category : #'as yet unclassified' }
SLVMPharoFunctionCodeGenerator >> withSequence: newSequence do: aBlock [
	| oldSequence |
	oldSequence := currentSequence.
	currentSequence := newSequence.
	aBlock ensure: [ currentSequence := oldSequence ]
]

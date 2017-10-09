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
		'thenSequences'
	],
	#classVars : [
		'BinaryOperationMessageMap'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #initialization }
SLVMPharoFunctionCodeGenerator class >> initialize [
	super initialize.
	
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
		dynObjectIdentityNotEquals #'~='
		
		mulMatrixMatrix *
		mulMatrixVector *
		mulVectorMatrix *
	)
]

{ #category : #'bytecode construction' }
SLVMPharoFunctionCodeGenerator >> add: anInstruction [
	anInstruction sourceNode: currentSourceLocation.
	anInstruction bytecodeIndex: self newBytecodeIndex.
	currentSequence add: anInstruction
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
SLVMPharoFunctionCodeGenerator >> convertPointerIntoVariable: aVariableExpression [
	| binding |
	(promotedAllocas includesKey: aVariableExpression) ifTrue: [ 
		^ promotedAllocas at: aVariableExpression.
	].
	
	aVariableExpression isGlobalVariable ifTrue: [
		binding := moduleTranslator translateElement: aVariableExpression.
		^ SLVMPharoLiteralVariable new binding: binding
	].

	^ nil

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
			temp := self createTemporary: arg validName type: arg type.
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
SLVMPharoFunctionCodeGenerator >> createTemporary: rawName type: type [
	| tempMap tempName index temp name |
	tempMap := self currentScope tempMap.
	name := rawName asSymbol.
	tempName := tempMap at: name ifPresent: [('<temp:' , tempMap size asString, '>') asSymbol] ifAbsent: [ name ].
	
	index := tempMap size + 1.
	temp := SLVMPharoFunctionLocal new name: name; type: type; yourself.
	tempMap at: tempName put: index.
	^ temp
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
			send: #+.
	].

	indicesWithStrides do: [ :pair |
		self
			visitExpression: pair first;
			pushLiteral: pair second;
			send: #*;
			send: #+
	].

]

{ #category : #initialization }
SLVMPharoFunctionCodeGenerator >> initialize [
	super initialize.
	currentSourceLocation := nullSourceLocation := SLVMDebugLocation null.
	lastBytecodeIndex := 0.
	nextSequenceIndex := 0.
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> isObjectElementPointer: expression [
	^ expression isGetElementPointer and: [ expression pointer type isDynamicObjectType ]
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> loadValueFromPointer: anInstruction [
	self visitExpression: anInstruction variable.
	self send: anInstruction type selectorForLoadingFromPointer
]

{ #category : #accessing }
SLVMPharoFunctionCodeGenerator >> moduleTranslator [
	^ moduleTranslator
]

{ #category : #accessing }
SLVMPharoFunctionCodeGenerator >> moduleTranslator: anObject [
	moduleTranslator := anObject
]

{ #category : #'bytecode construction' }
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

{ #category : #'bytecode construction' }
SLVMPharoFunctionCodeGenerator >> popTopOfType: aType [
	aType isVoidType ifTrue: [ ^ self ].
	self popTop
]

{ #category : #'bytecode construction' }
SLVMPharoFunctionCodeGenerator >> pushConsArray: size [

	self add: (IRInstruction pushConsArray: size)
]

{ #category : #'bytecode construction' }
SLVMPharoFunctionCodeGenerator >> pushLiteral: object [

	self add: (IRInstruction pushLiteral: object)
]

{ #category : #'bytecode construction' }
SLVMPharoFunctionCodeGenerator >> pushLiteralVariable: object [

	self add: (IRInstruction pushLiteralVariable: object)
]

{ #category : #'bytecode construction' }
SLVMPharoFunctionCodeGenerator >> pushReceiver [

	self add: (IRInstruction pushReceiver)
]

{ #category : #'bytecode construction' }
SLVMPharoFunctionCodeGenerator >> pushTemp: aSymbol [

	^ self add: (IRInstruction pushTemp: aSymbol)
]

{ #category : #'bytecode construction' }
SLVMPharoFunctionCodeGenerator >> returnTop [

	self add: IRInstruction returnTop.
]

{ #category : #'bytecode construction' }
SLVMPharoFunctionCodeGenerator >> send: selector [

	^self add: (IRInstruction send: selector)
]

{ #category : #'bytecode construction' }
SLVMPharoFunctionCodeGenerator >> storeTemp: aSymbol [

	^self add: (IRInstruction storeTemp: aSymbol)
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> storeValueIntoPointer: anInstruction [
	self visitExpression: anInstruction variable.
	self visitExpression: anInstruction value.
	self send: anInstruction value type selectorForStoringIntoPointer.
	self popTop.
]

{ #category : #'code generation' }
SLVMPharoFunctionCodeGenerator >> translateBasicBlock: basicBlock into: sequence [
	currentSequence := sequence.
	currentBasicBlock := basicBlock.
	basicBlock statementsDo: [ :statement |
		self translateStatement: statement.
		statement expression isTerminator ifTrue: [ ^ self ].
		(promotedAllocas includesKey: statement) ifFalse: [ 
			self popTopOfType: statement type
		]
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
	
	translatedElements := IdentityDictionary new.
	elseSequences := IdentityDictionary new.
	thenSequences := IdentityDictionary new.
	basicBlockMap := OrderedCollection new.
	promotedAllocas := IdentityDictionary new.
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

	trailer := CompiledMethodTrailer empty.
	aFunction debugSourceLocation ifNotNil: [
		aFunction debugSourceLocation sourceCode ifNotNil: [:sourceCode |
			trailer sourceCode: sourceCode
		]
	].
	
	compiledMethod := ir optimize compiledMethodWith: trailer.

	etreeFunction classBinding ifNotNil: [ 
		compiledMethod classBinding: etreeFunction classBinding
	].
	etreeFunction selector ifNotNil: [ 
		compiledMethod selector: etreeFunction selector
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
		(translatedElements at: statement) emitStoreStackTopWith: self.
	].

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
SLVMPharoFunctionCodeGenerator >> visitBranch: aBranch [
	| elseSequence thenSequence |
	self visitExpression: aBranch condition.
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
	self pushLiteral: nil.
	arguments := anInstruction arguments.
	arguments do: [ :arg | self visitExpression: arg ].
	self pushConsArray: arguments size.
	self send: #valueWithReceiver:arguments:
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitConstantDynamicLiteral: aLiteralConstant [
	self pushLiteral: aLiteralConstant value
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitConstantValue: aConstant [
	self pushLiteral: aConstant value
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitDynamicObjectToFloatCast: cast [
	self visitExpression: cast source
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitDynamicObjectToIntCast: cast [
	self visitExpression: cast source
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitETreeStatement: anStatement [
	(translatedElements at: anStatement) emitPushWith: self
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
SLVMPharoFunctionCodeGenerator >> visitFloatToDynamicObjectCast: cast [
	self visitExpression: cast source
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitFloatToIntCast: cast [
	self visitExpression: cast source.
	self send: #asInteger
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitFunction: aFunction [
	| translatedFunction |
	translatedFunction := moduleTranslator translateElement: aFunction.
	self pushLiteralVariable: translatedFunction
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitFunctionArgument: anArgument [
	(translatedElements at: anArgument) emitPushWith: self
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitGetElementPointer: anInstruction [
	self assert: anInstruction type isDynamicObjectType not.

	self visitExpression: anInstruction pointer.
	self emitGetElementPointerOffsets: anInstruction.

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

	variable emitPushWith: self
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitMessageSend: anInstruction [
	| selector arguments |
	self visitExpression: anInstruction receiver.
	
	selector := anInstruction selector.
	arguments := anInstruction arguments.
	(selector isConstantDynamicLiteral and: [selector value isSymbol]) ifTrue: [
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
	anInstruction value type isVoidType ifTrue: [
		self pushReceiver
	].
	self returnTop
]

{ #category : #visiting }
SLVMPharoFunctionCodeGenerator >> visitStore: anInstruction [
	| variable |
	variable := self convertPointerIntoVariable: anInstruction variable.
	variable ifNil: [ 
		^ self storeValueIntoPointer: anInstruction
	].

	self visitExpression: anInstruction value.
	variable emitStoreStackTopWith: self.
	self popTopOfType: anInstruction value type.
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

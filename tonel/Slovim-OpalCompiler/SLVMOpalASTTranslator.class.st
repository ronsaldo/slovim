Class {
	#name : #SLVMOpalASTTranslator,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'compilationTarget',
		'methodIR',
		'currentScope',
		'irBuilder',
		'allocaBuilder',
		'module'
	],
	#classVars : [
		'OptimizedMessages'
	],
	#category : #'Slovim-OpalCompiler-Translator'
}

{ #category : #'class initialization' }
SLVMOpalASTTranslator class >> initialize [
	"self initialize"
	
	super initialize.
	
	OptimizedMessages := { 
	#caseOf: -> #emitCaseOf:receiver: .
	#caseOf:otherwise: -> #emitCaseOfOtherwise:receiver: .
	#ifFalse: -> #emitIfFalse:receiver: .
	#ifFalse:ifTrue: -> #emitIfFalseIfTrue:receiver: .
	#ifNil: -> #emitIfNil:receiver: .
	#ifNil:ifNotNil: -> #emitIfNilIfNotNil:receiver: .
	#ifNotNil: -> #emitIfNotNil:receiver: .
	#ifNotNil:ifNil: -> #emitIfNotNilIfNil:receiver: .
	#ifTrue: -> #emitIfTrue:receiver: .
	#ifTrue:ifFalse: -> #emitIfTrueIfFalse:receiver: .
	#or: -> #emitOr:receiver: .
	#and: -> #emitAnd:receiver: .
	#timesRepeat: -> #emitTimesRepeat:receiver: .
	#repeat -> #emitRepeat:receiver: .
	#to:by:do: -> #emitToByDo:receiver: .
	#to:do: -> #emitToDo:receiver: .
	#whileFalse: -> #emitWhileFalse:receiver: .
	#whileTrue: -> #emitWhileTrue:receiver: .
	#whileFalse -> #emitWhileFalse:receiver: .
	#whileTrue -> #emitWhileTrue:
	 } asDictionary
]

{ #category : #visiting }
SLVMOpalASTTranslator >> closureCopiedValuesBase [
	^ 4
]

{ #category : #'primitive functions' }
SLVMOpalASTTranslator >> createFullBlockClosureFunction [
	^ self getRuntimeSmalltalkFunction: #slvm_dynrun_primitive_createFullBlockClosure signature: [:ct |
		{
			"Outer context" ct dynamicObjectType .
			"Receiver" ct dynamicObjectType .
			"Compiled Method" ct dynamicObjectType .
			"Copied parameters size" ct uint .
		} -> ct dynamicObjectType
	]
]

{ #category : #'as yet unclassified' }
SLVMOpalASTTranslator >> createTempVectorForScope: scope [
	| tempVectorSize tempVectorName tempVectorValue |
	self flag: 'Add support for mixed object/data vectors.'.
	tempVectorSize := scope tempVector size.

	"Allocate the temp vector"
	tempVectorValue := irBuilder call: self tempVectorCreationFunction arguments: { irBuilder constUInt: tempVectorSize }.
	tempVectorValue setPrimitiveCall.
	
	tempVectorName := scope tempVectorName.
	currentScope addValue: tempVectorValue symbol: scope tempVectorName.
	scope tempVector doWithIndex: [ :each :index|
		currentScope addBlock: [ :builder :lookupScope |
			| tempVectorPointer |
			tempVectorPointer := lookupScope lookSymbolRecursively: tempVectorName withBuilder: builder.
			builder getReference: tempVectorPointer element: (builder constInt: index - 1)
		] symbol: each name
	].

]

{ #category : #'visitor-double dispatching' }
SLVMOpalASTTranslator >> createThisContextEmitter [
	^ [ :builder |
		| call |
		call := builder call: self marryThisContextFunction arguments: { builder getFramePointer }.
		call
			setPrimitiveCall;
			setGetThisContext.
		call
		]
]

{ #category : #'inline messages' }
SLVMOpalASTTranslator >> emitBranch: aMessageNode trueValue: trueValue falseValue: falseValue receiver: receiverValue [
	| trueBlock mergeBlock condition branch trueResult result falseBlock falseResult trueBlockTerminated falseBlockTerminated |
	trueBlock := irBuilder newBasicBlock: #branchTrueThen.
	falseBlock := irBuilder newBasicBlock: #branchFalseThen.
	mergeBlock := irBuilder newBasicBlock: #branchMerge.

	condition := irBuilder dynObjectIdentityEquals: receiverValue with: (irBuilder addDynamicLiteral: trueValue).
	branch := irBuilder branch: condition ifTrue: trueBlock ifFalse: falseBlock.
	branch mergeBlock: mergeBlock.

	"True block"
	irBuilder currentBlock: trueBlock.
	trueResult := self visitInlinedBlockNode: aMessageNode arguments first arguments: #().
	trueBlock := irBuilder currentBlock.

	trueBlockTerminated := irBuilder isLastTerminator.
	trueBlockTerminated ifFalse: [
		irBuilder jump: mergeBlock.
	].

	"False block content"
	irBuilder currentBlock: falseBlock.
	falseResult := self visitInlinedBlockNode: aMessageNode arguments second arguments: #().
	falseBlock := irBuilder currentBlock.

	falseBlockTerminated := irBuilder isLastTerminator.
	falseBlockTerminated ifFalse: [
		irBuilder jump: mergeBlock.
	].

	"Merge block"
	irBuilder currentBlock: mergeBlock.
	branch addUnreachableSuccessors.
	(trueBlockTerminated and: [ falseBlockTerminated ]) ifTrue: [ 
		irBuilder unreachable.
		^ irBuilder addDynamicLiteral: nil
	].

	falseBlockTerminated ifTrue: [
		^ trueResult
	].

	trueBlockTerminated ifTrue: [
		^ falseResult
	].
	
	result := irBuilder phi: compilationTarget dynamicObjectType name: #branchOnceResult.
	result addValue: trueResult from: trueBlock.
	result addValue: falseResult from: falseBlock.
	^ result
]

{ #category : #'inline messages' }
SLVMOpalASTTranslator >> emitBranchOnce: aMessageNode trueValue: trueValue receiver: receiverValue [
	| thenBlock mergeBlock condition branch trueResult result |
	thenBlock := irBuilder newBasicBlock: #branchOnceThen.
	mergeBlock := irBuilder newBasicBlock: #branchOnceMerge.

	condition := irBuilder dynObjectIdentityEquals: receiverValue with: (irBuilder addDynamicLiteral: trueValue).
	branch := irBuilder branch: condition ifTrue: thenBlock ifFalse: mergeBlock.
	branch mergeBlock: mergeBlock.
	irBuilder currentBlock: thenBlock.
	
	trueResult := self visitInlinedBlockNode: aMessageNode arguments first arguments: #().
	thenBlock := irBuilder currentBlock.

	irBuilder isLastTerminator ifTrue: [
		irBuilder currentBlock: mergeBlock.
		^ irBuilder addDynamicLiteral: nil
	] ifFalse: [
		irBuilder jump: mergeBlock.
		irBuilder currentBlock: mergeBlock.
	].

	result := irBuilder phi: compilationTarget dynamicObjectType name: #branchOnceResult.
	result addValue: trueResult from: thenBlock.
	result addValue: (irBuilder addDynamicLiteral: nil) from: branch block.
	^ result
]

{ #category : #'inline messages' }
SLVMOpalASTTranslator >> emitIfFalse: aMessageNode receiver: receiverValue [
	^ self emitBranchOnce: aMessageNode trueValue: false receiver: receiverValue
]

{ #category : #'inline messages' }
SLVMOpalASTTranslator >> emitIfFalseIfTrue: aMessageNode receiver: receiverValue [
	^ self emitBranch: aMessageNode trueValue: false falseValue: true receiver: receiverValue
	
]

{ #category : #'inline messages' }
SLVMOpalASTTranslator >> emitIfTrue: aMessageNode receiver: receiverValue [
	^ self emitBranchOnce: aMessageNode trueValue: true receiver: receiverValue
]

{ #category : #'inline messages' }
SLVMOpalASTTranslator >> emitIfTrueIfFalse: aMessageNode receiver: receiverValue [
	^ self emitBranch: aMessageNode trueValue: true falseValue: false receiver: receiverValue
	
]

{ #category : #'visitor-double dispatching' }
SLVMOpalASTTranslator >> emitMessageNode: aMessageNode [
	self assert: aMessageNode isCascaded not.
	^ self emitMessageNode: aMessageNode receiver: (self visitNode: aMessageNode receiver)
]

{ #category : #'visitor-double dispatching' }
SLVMOpalASTTranslator >> emitMessageNode: aMessageNode receiver: receiverValue [
	| arguments |
	arguments := aMessageNode arguments collect: [ :arg | self visitNode: arg ].
	^ aMessageNode isSuperSend
		ifTrue: [ self halt. ]
		ifFalse: [ irBuilder
			send: (irBuilder addDynamicLiteral: aMessageNode selector) 
			returnType: compilationTarget dynamicObjectType
			receiver: receiverValue
			arguments: arguments ]
]

{ #category : #'inline messages' }
SLVMOpalASTTranslator >> emitToByDo: aMessageNode receiver: receiverValue [

	| step |
	
	step := aMessageNode arguments second.
	step isLiteralNode ifFalse: [self error: 'should not have been inlined'].
	step := step value.

	self emitToDo: aMessageNode receiver: receiverValue step: step
]

{ #category : #'inline messages' }
SLVMOpalASTTranslator >> emitToDo: aMessageNode receiver: receiverValue [
	
	self emitToDo: aMessageNode receiver: receiverValue step: 1
]

{ #category : #'inline messages factored' }
SLVMOpalASTTranslator >> emitToDo: aMessageNode receiver: receiverValue step: step [
	| limit block counterVar loopHeader loopBody loopMerge condition branch iterationValue |
	
	limit := self visitNode: aMessageNode arguments first.
	block := aMessageNode arguments last.

	counterVar := allocaBuilder alloca: compilationTarget dynamicObjectType name: #toDoCounter.
	irBuilder store: receiverValue in: counterVar.
	
	loopHeader := irBuilder newBasicBlock: #toDoHeader.
	loopBody := irBuilder newBasicBlock: #toDoBody.
	loopMerge := irBuilder newBasicBlock: #toDoMerge.
	
	"Loop header"
	irBuilder
		jump: loopHeader;
		currentBlock: loopHeader.
		
	condition := irBuilder
		send: (irBuilder addDynamicLiteral: (step >= 0 ifTrue: [ #<= ] ifFalse: [ #>=]))
		returnType: compilationTarget dynamicObjectType
		receiver: (irBuilder load: counterVar)
		arguments: { limit }.
	condition := irBuilder dynObjectIdentityEquals: condition with: (irBuilder addDynamicLiteral: true).
	
	branch := irBuilder branch: condition ifTrue: loopBody ifFalse: loopMerge.
	branch
		continueBlock: loopHeader;
		mergeBlock: loopMerge.
		
	"Loop body"
	irBuilder currentBlock: loopBody.
	iterationValue := irBuilder load: counterVar.
	 
	self visitInlinedBlockNode: aMessageNode arguments last arguments: { iterationValue }.
	irBuilder isLastTerminator ifFalse: [ irBuilder jump: loopHeader ].
	
	"Loop merge"
	irBuilder currentBlock: loopMerge.
	^ receiverValue
]

{ #category : #'as yet unclassified' }
SLVMOpalASTTranslator >> function: newFunction build: aBinaryBlock [
	| oldAllocaBuilder oldIRBuilder allocaBlock contentBlock oldCurrentScope |
	oldAllocaBuilder := allocaBuilder.
	oldIRBuilder := irBuilder.
	oldCurrentScope := currentScope.
	
	currentScope := SLVMOpalLocalScope new parentScope: oldCurrentScope.
	
	allocaBuilder := SLVMBuilder on: newFunction.
	allocaBlock := allocaBuilder newBasicBlock: #temps.
	allocaBuilder currentBlock: allocaBlock.
	
	irBuilder := SLVMBuilder on: newFunction.
	contentBlock := irBuilder newBasicBlock: #content.
	irBuilder currentBlock: contentBlock.
	
	[
		aBinaryBlock value: allocaBlock value: contentBlock.
	] ensure: [
		allocaBuilder := oldAllocaBuilder.
		irBuilder := oldIRBuilder.
		currentScope := oldCurrentScope.
	]

]

{ #category : #'as yet unclassified' }
SLVMOpalASTTranslator >> getReceiverValue [
	^ currentScope selfValue
]

{ #category : #'primitive functions' }
SLVMOpalASTTranslator >> getRuntimeSmalltalkFunction: name signature: signatureBlock [
	^ module globalValues at: name ifAbsent: [ 
		| signature |
		signature := signatureBlock value: compilationTarget.
		(module functionName: name callingConvention: #smalltalk arguments: signature key returnType: signature value)
			makeExternal
	].
]

{ #category : #'as yet unclassified' }
SLVMOpalASTTranslator >> getThisContextValue: scope [
	| thisContextVar |
	thisContextVar := scope lookupVar: #thisContext.
	^ thisContextVar emitSLVMValue: irBuilder scope: currentScope.
]

{ #category : #accessing }
SLVMOpalASTTranslator >> ir [
	^ methodIR
]

{ #category : #'primitive functions' }
SLVMOpalASTTranslator >> marryThisContextFunction [
	^ self getRuntimeSmalltalkFunction: #slvm_dynrun_primitive_marryThisContext signature: [:ct |
		{
			"Frame pointer" ct pointerTo: ct void .
		} -> ct dynamicObjectType
	]
]

{ #category : #'primitive functions' }
SLVMOpalASTTranslator >> tempVectorCreationFunction [
	^ self getRuntimeSmalltalkFunction: #slvm_dynrun_primitive_tempVectorCreate signature: [:ct |
		{ ct uint } -> ct dynamicObjectType
	]
]

{ #category : #visiting }
SLVMOpalASTTranslator >> visitAssignmentNode: anAssignmentNode [ 
	| value |
	value := self visitNode: anAssignmentNode value.
	anAssignmentNode variable binding emitSLVM: irBuilder store: value scope: currentScope.
	^ value
]

{ #category : #visiting }
SLVMOpalASTTranslator >> visitBlockNode: aBlockNode [
	| objectType blockArgumentTypes blockFunctionType blockFunction nodeScope thisContextValue receiverValue closureValue copiedNames copiedValue copiedPointer receiverIndex arguments blockClosureSelf closureReceiver argValue blockLocalResult |
	self assert: aBlockNode isInlined not.
	
	objectType := compilationTarget dynamicObjectType.
	blockArgumentTypes := {"receiver" objectType} , aBlockNode arguments collect: [ :arg | objectType ].
	blockFunctionType := SLVMFunctionType callingConvention: #smalltalk arguments: blockArgumentTypes returnType: objectType.
	copiedNames := aBlockNode scope inComingCopiedVars asArray collect: #name.
	
	blockFunction := SLVMFunction pointerSize: compilationTarget pointerSize functionType: blockFunctionType.
	blockFunction
		compilationTarget: compilationTarget;
		needsCompiledMethodObject: true;
		makePrivate.
	module add: blockFunction.
	self flag: 'TODO: Try to add the closure indirectly to the module'.
	
	receiverIndex := (FullBlockClosure instVarIndexFor: #receiver) - 1.
	
	self function: blockFunction build: [ :allocaBlock :contentBlock |
		arguments := blockFunction arguments.
		
		"Add the arguments to the scope"
		aBlockNode arguments doWithIndex: [ :arg :index |
			argValue := arguments at: index + 1.
			argValue name: arg name.
			currentScope addValue: argValue symbol: arg name.
		].

		"Fetch the receiver"
		blockClosureSelf := arguments first name: #blockClosure.
		closureReceiver := irBuilder load: (irBuilder getReference: blockClosureSelf element: (irBuilder constUInt: receiverIndex)) name: #self.
		currentScope selfValue: closureReceiver.
	
		"Put the copied in the closure scope."
		copiedNames doWithIndex: [ :name :index |
			copiedPointer := irBuilder getReference: blockClosureSelf element: (irBuilder constInt: self closureCopiedValuesBase + index - 1).
			copiedValue := irBuilder load: copiedPointer name: name.
			currentScope addValue: copiedValue symbol: name
		].
	
		"Translate the block body."
		blockLocalResult := self visitNode: aBlockNode body.
		
		"Finsh the closure code."
		allocaBuilder jump: contentBlock.
		irBuilder isLastTerminator ifFalse: [
			irBuilder return: blockLocalResult
		]
	].
	
	nodeScope := aBlockNode parent scope.
	thisContextValue := self getThisContextValue: nodeScope.
	receiverValue := self getReceiverValue.
	closureValue := irBuilder call: (self createFullBlockClosureFunction) arguments: {
		thisContextValue .
		receiverValue .
		blockFunction compiledMethodMetaDataValue.
		irBuilder constUInt: copiedNames size.
	}.
	closureValue setPrimitiveCall.
	
	"Copy the values in the closure."
	copiedNames doWithIndex: [ :name :index |
		"Evaluate the copied variables."
		copiedValue := currentScope lookSymbolRecursively: name withBuilder: irBuilder.
		(copiedValue isInstruction and: [ copiedValue isAlloca ]) ifTrue: [ 
			copiedValue := irBuilder load: copiedValue
		].
	
		"Copy the value into the block closure."
		copiedPointer := irBuilder getReference: closureValue element: (irBuilder constInt: self closureCopiedValuesBase + index - 1).
		irBuilder store: copiedValue in: copiedPointer.
	].

	^ closureValue
]

{ #category : #'visitor-double dispatching' }
SLVMOpalASTTranslator >> visitInlinedBlockNode: anOptimizedBlockNode arguments: argumentValues [

	"We are visiting a scope that is not a block, but inlined in the outer context.
	This means: 
			- we do not create a block
			- we call alloca builder to add temps
	"
	| argumentNames tempNames innerScope objectType tempVariables nilValue |
	argumentNames := anOptimizedBlockNode argumentNames asArray.
	tempNames := (anOptimizedBlockNode scope tempVars collect: [ :each | each name asSymbol] as: Array) copyWithoutAll: argumentNames.
	
	innerScope := SLVMOpalLocalScope new
		selfValue: currentScope selfValue;
		parentScope: currentScope.
	objectType := compilationTarget dynamicObjectType.
	tempVariables := tempNames collect: [ :tempName | allocaBuilder alloca: objectType name: tempName  ].
	argumentNames doWithIndex: [:argName :index |
		innerScope addValue: (argumentValues at: index) symbol: argName
	].

	tempVariables doWithIndex: [:tempVar :index |
		innerScope addValue: tempVar symbol: (tempNames at: index)
	].
	
	self withScope: innerScope do: [
		anOptimizedBlockNode scope tempVector ifNotEmpty: [
			self halt.
		].
	
		anOptimizedBlockNode isInlinedLoop ifTrue: [
			nilValue := irBuilder addDynamicLiteral: nil.
			tempVariables do: [ :temp | irBuilder store: nilValue in: temp ]
		].
	
		^ self visitNode: anOptimizedBlockNode body.
	].
]

{ #category : #'visitor-double dispatching' }
SLVMOpalASTTranslator >> visitLiteralNode: aLiteralNode [
	^ irBuilder addDynamicLiteral: aLiteralNode value
]

{ #category : #'visitor-double dispatching' }
SLVMOpalASTTranslator >> visitMessageNode: aMessageNode [
	| receiver |
	self assert: aMessageNode isCascaded not.
	aMessageNode isInlined ifTrue: [
		irBuilder addDynamicLiteral: aMessageNode selector. "so searching for senders will work"
		receiver := self visitNode: aMessageNode receiver.
		^self 
			perform: (OptimizedMessages at: aMessageNode selector)
			with: aMessageNode
			with: receiver].
	^ self emitMessageNode: aMessageNode
]

{ #category : #'visitor-double dispatching' }
SLVMOpalASTTranslator >> visitMethodNode: aMethodNode [
	| objectType argumentTypes functionType arguments argValue local callingConvention methodFunction |
	compilationTarget := aMethodNode compilationContext compilationTarget.
	module := aMethodNode compilationContext module.
	objectType := compilationTarget dynamicObjectType.
	callingConvention := #smalltalk.
	aMethodNode pragmaNamed: #callingConvention: ifPresent: [ :callingConventionPragma |
		callingConvention := callingConventionPragma arguments first value
	].

	argumentTypes := {"receiver" objectType} , (aMethodNode arguments collect: [ :arg | objectType ]).
	functionType := SLVMFunctionType callingConvention: callingConvention arguments: argumentTypes returnType: objectType.
	
	methodFunction := SLVMFunction pointerSize: compilationTarget pointerSize functionType: functionType.
	methodFunction compilationTarget: aMethodNode compilationContext compilationTarget.
	methodIR := SLVMOpalMethodIR new function: methodFunction.
	self function: methodFunction build: [ :allocaBlock :contentBlock |
		arguments := methodFunction arguments.
		currentScope selfValue: (arguments first name: #self; yourself).
		currentScope thisContextEmitter: self createThisContextEmitter.
		aMethodNode arguments doWithIndex: [ :arg :index |
			argValue := arguments at: index + 1.
			argValue name: arg name.
			currentScope addValue: argValue symbol: arg name.
		].

		aMethodNode scope tempVarNames do: [ :tempName |
			(currentScope includesSymbol: tempName) ifFalse: [
				local := allocaBuilder alloca: objectType name: tempName.
				currentScope addValue: local symbol: tempName.
			]
		].

		aMethodNode scope tempVector ifNotEmpty: [
			self createTempVectorForScope: aMethodNode scope
		].
	
		self visitNode: aMethodNode body.
		allocaBuilder jump: contentBlock.
		irBuilder isLastTerminator ifFalse: [
			irBuilder return: currentScope selfValue
		]
	].

]

{ #category : #'visitor-double dispatching' }
SLVMOpalASTTranslator >> visitReturnNode: aReturnNode [
	irBuilder return: (self visitNode: aReturnNode value).
	^ nil
]

{ #category : #visiting }
SLVMOpalASTTranslator >> visitSequenceNode: aSequenceNode [ 
	| result |
	result := irBuilder addDynamicLiteral: nil.
	aSequenceNode statements do: [:each | result := self visitNode: each].
	^ result
]

{ #category : #'visitor-double dispatching' }
SLVMOpalASTTranslator >> visitVariableNode: aVariableNode [
	^ aVariableNode binding emitSLVMValue: irBuilder scope: currentScope

]

{ #category : #scope }
SLVMOpalASTTranslator >> withScope: scope do: aBlock [
	| oldScope |
	oldScope := currentScope.
	currentScope := scope.
	aBlock ensure: [ currentScope := oldScope ]
]

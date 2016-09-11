Class {
	#name : #SLVMOpalASTTranslator,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'compilationTarget',
		'methodIR',
		'currentScope',
		'irBuilder',
		'allocaBuilder'
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

{ #category : #'inline messages' }
SLVMOpalASTTranslator >> emitIfTrue: aMessageNode receiver: receiverValue [
	| thenBlock mergeBlock condition branch trueResult result |
	thenBlock := irBuilder newBasicBlock: #ifTrueThen.
	mergeBlock := irBuilder newBasicBlock: #ifTrueMerge.

	condition := irBuilder dynObjectIdentityEquals: receiverValue with: (irBuilder addDynamicLiteral: true).
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

	result := irBuilder phi: compilationTarget dynamicObjectType name: #ifTrueResult.
	result addValue: trueResult from: thenBlock.
	result addValue: (irBuilder addDynamicLiteral: nil) from: branch block.
	^ result
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

{ #category : #initialization }
SLVMOpalASTTranslator >> initialize [
	compilationTarget := SLVM32BitsPointerCompilationTarget new.
]

{ #category : #accessing }
SLVMOpalASTTranslator >> ir [
	^ methodIR
]

{ #category : #'as yet unclassified' }
SLVMOpalASTTranslator >> visitAssignmentNode: anAssignmentNode [ 
	| value |
	value := self visitNode: anAssignmentNode value.
	anAssignmentNode variable binding emitSLVM: irBuilder store: value scope: currentScope.
	^ value

]

{ #category : #'as yet unclassified' }
SLVMOpalASTTranslator >> visitBlockNode: aBlockNode [ 
	self halt.
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
	| objectType argumentTypes functionType currentFunction arguments argValue allocaBlock local contentBlock |
	objectType := compilationTarget dynamicObjectType.
	argumentTypes := {objectType} , aMethodNode arguments collect: [ :arg | objectType ].
	functionType := SLVMFunctionType arguments: argumentTypes returnType: objectType.
	
	currentFunction := SLVMFunction pointerSize: compilationTarget pointerSize functionType: functionType.
	currentFunction compilationTarget: aMethodNode compilationContext compilationTarget.
	methodIR := SLVMOpalMethodIR new function: currentFunction.
	
	currentScope := SLVMOpalLocalScope new.
	arguments := currentFunction arguments.
	currentScope selfValue: (arguments first name: #self; yourself).
	aMethodNode arguments doWithIndex: [ :arg :index |
		argValue := arguments at: index + 1.
		argValue name: arg name.
		currentScope addValue: argValue symbol: arg name.
	].

	allocaBuilder := SLVMBuilder on: currentFunction.
	allocaBlock := allocaBuilder newBasicBlock: #temps.
	allocaBuilder currentBlock: allocaBlock.
	
	irBuilder := SLVMBuilder on: currentFunction.
	contentBlock := irBuilder newBasicBlock: #content.
	irBuilder currentBlock: contentBlock.
	
	aMethodNode scope tempVarNames do: [ :tempName |
		(currentScope includesSymbol: tempName) ifFalse: [
			local := allocaBuilder alloca: objectType name: tempName.
			currentScope addValue: local symbol: tempName.
		]
	].

	aMethodNode scope tempVector ifNotEmpty: [
		self halt
	].
	
	self visitNode: aMethodNode body.
	
	allocaBuilder jump: contentBlock.
	irBuilder isLastTerminator ifFalse: [
		irBuilder return: currentScope selfValue
	]
]

{ #category : #'visitor-double dispatching' }
SLVMOpalASTTranslator >> visitReturnNode: aReturnNode [
	irBuilder return: (self visitNode: aReturnNode value).
	^ nil
]

{ #category : #'as yet unclassified' }
SLVMOpalASTTranslator >> visitSequenceNode: aSequenceNode [ 
	| result |
	self visitTemporaryNodes: aSequenceNode temporaries.
	result := irBuilder addDynamicLiteral: nil.
	aSequenceNode statements do: [:each | result := self visitNode: each].
	^ result
]

{ #category : #'visitor-double dispatching' }
SLVMOpalASTTranslator >> visitVariableNode: aVariableNode [
	^ aVariableNode binding emitSLVMValue: irBuilder scope: currentScope

]

{ #category : #'as yet unclassified' }
SLVMOpalASTTranslator >> withScope: scope do: aBlock [
	| oldScope |
	oldScope := currentScope.
	currentScope := scope.
	aBlock ensure: [ currentScope := oldScope ]
]

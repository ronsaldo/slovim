"
I represent a function.
"
Class {
	#name : #SLVMFunction,
	#superclass : #SLVMGlobalValue,
	#instVars : [
		'basicBlocks',
		'functionType',
		'type',
		'arguments',
		'postOrder',
		'preOrder',
		'haveDominance',
		'dynamicLiterals',
		'compilationTarget',
		'needsCompiledMethodObject',
		'personalityFunction',
		'localValueIndexComputationCount'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMFunction class >> mnemonic [
	^ #function
]

{ #category : #construction }
SLVMFunction class >> module: module name: varName functionType: functionType [
	| var |
	var := self pointerSize: module compilationTarget pointerSize name: varName functionType: functionType.
	var compilationTarget: module compilationTarget.
	module add: var.
	^ var
]

{ #category : #construction }
SLVMFunction class >> pointerSize: pointerSize functionType: aFunctionType [
	^ self new pointerSize: pointerSize functionType: aFunctionType; yourself
]

{ #category : #construction }
SLVMFunction class >> pointerSize: pointerSize name: aString functionType: aFunctionType [
	^ self new name: aString; pointerSize: pointerSize functionType: aFunctionType; yourself
]

{ #category : #visitor }
SLVMFunction >> accept: aVisitor [
	^ aVisitor visitFunction: self
]

{ #category : #adding }
SLVMFunction >> addBasicBlock: aBasicBlock [
	basicBlocks add: aBasicBlock.
	aBasicBlock index: basicBlocks size.
	aBasicBlock function: self.
	self invalidateLocalValueIndices.
	self invalidateControlFlowCaches.
]

{ #category : #adding }
SLVMFunction >> addDynamicLiteral: literal [
	dynamicLiterals do: [ :lit | (lit value = literal and: [ lit value class == literal class ]) ifTrue: [ ^ lit ] ].
	^ self addRequiredDynamicLiteral: literal
]

{ #category : #adding }
SLVMFunction >> addRequiredDynamicLiteral: literal [
	| result nonInlineLiteral |
	nonInlineLiteral := (compilationTarget objectModel isInlineLiteral: literal)
		ifTrue: [ nil ]
		ifFalse: [ module getOrCreateNonInlineLiteralFor: literal ].
	result := SLVMFunctionDynamicLiteral new
		value: literal;
		index: dynamicLiterals size + 1;
		nonInlineLiteral: nonInlineLiteral;
		type: compilationTarget dynamicObjectType.
	dynamicLiterals add: result.
	^ result
]

{ #category : #adding }
SLVMFunction >> addRuntimeLiterals: literals [
	"Update the index of the literal"
	literals doWithIndex: [ :literal :i | literal index: dynamicLiterals size + i ].
	dynamicLiterals addAll: literals
]

{ #category : #enumerating }
SLVMFunction >> allInstructionsDo: aBlock [
	basicBlocks do: [ :bb |
		bb allInstructionsDo: aBlock
	]
]

{ #category : #'as yet unclassified' }
SLVMFunction >> allInstructionsMnemonics [
	"This is a method to facilitate the writing of tests"
	^ basicBlocks collect: [:bb | {bb name . bb allInstructionsMnemonics}] as: Array
]

{ #category : #enumerating }
SLVMFunction >> allModuleInstructionsDo: aBlock [
	self allInstructionsDo: [ :instruction |
		instruction allModuleInstructionsDo: aBlock
	]
]

{ #category : #'control flow' }
SLVMFunction >> applyDominanceTopoSort [
	basicBlocks := self dominanceTopoSort.
	basicBlocks doWithIndex: [ :bb :index | bb index: index ].
	self invalidateControlFlowCaches.
	
]

{ #category : #optimizations }
SLVMFunction >> applyFunctionOptimizationPasses: passes [
	passes do: [ :pass | pass passOnFunction: self ]
]

{ #category : #'as yet unclassified' }
SLVMFunction >> applyGCStrategy [
	self gcStrategy ifNotNil: [ :strategyName |
		self flag: 'Use a proper flag here.'.
		self gcStrategy: nil.
		(SLVMFunctionGCLoweringPass gcNamed: strategyName) passOnFunction: self
	]

]

{ #category : #accessing }
SLVMFunction >> arguments [
	^ arguments
]

{ #category : #accessing }
SLVMFunction >> argumentsDescriptor [
	<compileTime>
	^ functionType argumentsDescriptorWithTarget: compilationTarget
]

{ #category : #printing }
SLVMFunction >> asFullSExpression [
	^ { self mnemonic . self globalValueIndex . name . functionType callingConvention . functionType returnType asSExpression .
		self globalValueAttributesAsSExpression.
		#arguments . arguments collect: [ :each | each asFullSExpression ].
		#variadic . functionType variadic .
		#literals . dynamicLiterals collect: [ :each | each asFullSExpression ] as: Array.
		#blocks . self instructionsSExpressions.
	}
]

{ #category : #printing }
SLVMFunction >> asFullSExpressionForTesting [
	^ { self mnemonic . name . functionType callingConvention . functionType returnType asSExpression .
		#arguments . arguments collect: [ :each | each asFullSExpression ].
	}
	, (functionType variadic ifTrue: [ #( #variadic true ) ] ifFalse: [#()]) ,
	{
		#literals . dynamicLiterals collect: [ :each | each asFullSExpression ] as: Array.
		#blocks . self instructionsSExpressions.
	}
]

{ #category : #printing }
SLVMFunction >> asPrettyFullSExpressionForTesting [
	^ (ByteString streamContents: [ :out |
		| sexpr |
		sexpr := self asFullSExpressionForTesting.
		(sexpr first: 4) doWithIndex: [ :each :index |
			index > 1 ifTrue: [ out space ].
			out print: each.
		].
		out cr.
	
		(sexpr allButFirst: 4) pairsDo: [ :key :value |
			value isArray ifTrue: [ 
			out tab; print: key; nextPutAll: ' ('; cr.
			key = #blocks ifTrue: [
				value do: [ :each |
					self prettyPrintBlockSExpression: each into: out.
				].
			] ifFalse: [
				value do: [ :each |
					out tab; tab; print: each; cr.
				]					
			].
			out tab; nextPutAll: ')'; cr.
			] ifFalse: [
				out tab; print: key; space; print: value; cr.
			]
		]
	]) copyReplaceAll: '#' with: ''
]

{ #category : #accessing }
SLVMFunction >> basicBlocks [
	^ basicBlocks
]

{ #category : #building }
SLVMFunction >> build: aBlock [
	aBlock value: (SLVMBuilder on: self)
]

{ #category : #'as yet unclassified' }
SLVMFunction >> buildWithArguments: aBlock [
	aBlock valueWithArguments: { SLVMBuilder on: self } , arguments
]

{ #category : #accessing }
SLVMFunction >> callingConvention [
	^ functionType callingConvention
]

{ #category : #'control flow' }
SLVMFunction >> canHaveCanonicalStructuredControlFlow [
	^ self propertyAt: #canHaveCanonicalStructuredControlFlow ifAbsent: [ true ]
]

{ #category : #'control flow' }
SLVMFunction >> canHaveCanonicalStructuredControlFlow: aBoolean [
	^ self propertyAt: #canHaveCanonicalStructuredControlFlow put: aBoolean
]

{ #category : #accessing }
SLVMFunction >> childrenNodes [
	^ basicBlocks
]

{ #category : #testing }
SLVMFunction >> classBindingValue [
	^ dynamicLiterals last value
]

{ #category : #accessing }
SLVMFunction >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMFunction >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #accessing }
SLVMFunction >> compiledMethodMetaDataValue [
	^ SLVMConstantCompiledMethodMetaData new
		type: compilationTarget dynamicObjectType;
		sourceMethod: self
]

{ #category : #'control flow' }
SLVMFunction >> computeBackEdges [
	| colors |
	colors := Array new: basicBlocks size withAll: #white.
	basicBlocks do: [ :bb | bb backEdgesToMe: #() ].
	basicBlocks do: [ :bb | self computeBackEdgesFrom: bb colors: colors ].
]

{ #category : #'control flow' }
SLVMFunction >> computeBackEdgesFrom: basicBlock colors: visited [
	| color predColor |
	color := visited at: basicBlock index.
	color == #black ifTrue: [ ^ self ].
	self assert: color == #white.
	visited at: basicBlock index put: #gray.
	
	basicBlock successors do: [ :succ |
		predColor := visited at: succ index.
		predColor == #gray ifTrue: [
			succ addBackEdgeToMe: basicBlock
		] ifFalse: [
			self computeBackEdgesFrom: succ colors: visited
		]
	].

	visited at: basicBlock index put: #black.

]

{ #category : #'control flow' }
SLVMFunction >> computeDominance [
	"
	Dominance algorithm taken from paper 'A Simple, Fast Dominance Algorithm' by Cooper et al.
	"
	| reversePostOrder entryNode doms changed nodeIndex newIdom firstNewIdom block |
	(basicBlocks isEmpty or: [haveDominance]) ifTrue: [ ^ self ].
	
	reversePostOrder := self postOrder allButLast reversed.
	entryNode := basicBlocks first.
	doms := Array new: postOrder size withAll: -1.
	doms at: entryNode postOrderIndex put: entryNode postOrderIndex.
	changed := true.
	[ changed ] whileTrue: [
		changed := false.
		reversePostOrder do: [ :node |
			nodeIndex := node postOrderIndex.
			
			newIdom := (node predecessors detect: [ :pred | (doms at: pred postOrderIndex) >= 0]) postOrderIndex.
			self assert: newIdom isNotNil.
			
			firstNewIdom := newIdom.
			node predecessors do: [ :pred |
				(pred postOrderIndex ~= firstNewIdom and: [ (doms at: pred postOrderIndex) >= 0 ]) ifTrue: [ 
					newIdom := self dominances: doms intersect: pred postOrderIndex with: newIdom.
				] 
			].
			
			(doms at: nodeIndex) ~= newIdom ifTrue: [
				changed := true.
				doms at: nodeIndex put: newIdom
			]
		]
	].

	1 to: doms size do: [ :i |
		block := postOrder at: i.
		block immediateDominator: (postOrder at: (doms at: i)).
		block immediateDominator == block ifTrue: [ 
			block immediateDominator: nil
		]
	].

	self computeDominanceFrontiers.
	haveDominance := true.
]

{ #category : #'control flow' }
SLVMFunction >> computeDominanceFrontiers [
	| position end |
	
	"Reset the dominace frontiers."
	basicBlocks do: [ :bb | bb dominanceFrontier: Set new ].
	
	"Propagate up to the immediate dominator."
	basicBlocks do: [ :bb |
		bb predecessors size >= 2 ifTrue: [
			bb predecessors do: [ :pred |
				position := pred.
				end := bb immediateDominator.
				[ position ~~ end ] whileTrue: [
					position dominanceFrontier add: bb.
					position := position immediateDominator
				]
			]
		]
	].
	
]

{ #category : #'control flow' }
SLVMFunction >> computePostOrderFor: basicBlock visited: visitedArray [
	(visitedArray at: basicBlock index) ifTrue: [ ^ self ].
	visitedArray at: basicBlock index put: true.
	basicBlock successors do: [ :succ |
		self computePostOrderFor: succ visited: visitedArray.
	].

	postOrder add: basicBlock.
	basicBlock postOrderIndex: postOrder size.
]

{ #category : #'control flow' }
SLVMFunction >> computePreOrderFor: basicBlock visited: visitedArray [ 
	(visitedArray at: basicBlock index) ifTrue: [ ^ self ].
	visitedArray at: basicBlock index put: true.
	preOrder add: basicBlock.
	basicBlock preOrderIndex: preOrder size.
	
	basicBlock successors do: [ :succ |
		self computePreOrderFor: succ visited: visitedArray.
	].


]

{ #category : #copying }
SLVMFunction >> copyContentsInto: targetFunction valueMap: valueMap [
	^ self copyContentsInto: targetFunction valueMap: valueMap continuation: nil
]

{ #category : #copying }
SLVMFunction >> copyContentsInto: targetFunction valueMap: valueMap continuation: continuationBlock [
	| newBlocks newBlock substitutionDictionary newInstruction resultPhi return result movedAllocas sourceFirstBlock targetFirstBlock sourceFunction newDynamicLiteral allocaInsertionPoint runtimeLiterals |
	newBlocks := OrderedCollection new.
	movedAllocas := OrderedCollection new.
	substitutionDictionary := valueMap copy.
	
	runtimeLiterals := targetFunction removeRuntimeLiterals.
	dynamicLiterals isNotEmpty ifTrue: [
		targetFunction dynamicLiterals ifEmpty: [ 
			dynamicLiterals do: [ :lit |
				newDynamicLiteral := targetFunction addRequiredDynamicLiteral: lit value.
				substitutionDictionary at: lit put: newDynamicLiteral
			].
		] ifNotEmpty: [ 
			dynamicLiterals do: [ :lit |
				newDynamicLiteral := targetFunction addDynamicLiteral: lit value.
				substitutionDictionary at: lit put: newDynamicLiteral
			]
		]
	].

	targetFunction addRuntimeLiterals: runtimeLiterals.

	"Copy the vertices of the graph"
	sourceFunction := self.
	sourceFirstBlock := sourceFunction basicBlocks first.
	targetFirstBlock := targetFunction basicBlocks ifEmpty: [nil] ifNotEmpty: [targetFunction basicBlocks first].
	allocaInsertionPoint := nil.
	
	self basicBlocks do: [ :bb |
		newBlock := SLVMBasicBlock new
			copyingFrom: bb.
		newBlocks add: newBlock.
		targetFunction addBasicBlock: newBlock.
		substitutionDictionary at: bb put: newBlock.
		targetFirstBlock ifNil: [ targetFirstBlock := newBlock ].
		allocaInsertionPoint ifNil: [
			allocaInsertionPoint := targetFirstBlock instructionAfterAllocas.
		].
		
		bb instructionsDo: [ :instr |
			newInstruction := instr copy.
			
			substitutionDictionary at: instr put: newInstruction.
			(newInstruction isAlloca and: [ bb == sourceFirstBlock ]) ifTrue: [
				targetFirstBlock add: newInstruction before: allocaInsertionPoint.
				movedAllocas add: newInstruction.
			] ifFalse: [ 
				newBlock addQuiet: newInstruction
			]
		] 
	].

	"Fix the structure CFG nodes."
	newBlocks do: [ :bb | bb applySubstitutions: substitutionDictionary ].

	"Fix the edges of the graph"
	movedAllocas do: [ :instr | instr applySubstitutions: substitutionDictionary ].
	newBlocks do: [ :bb |
		bb instructionsDo: [ :instr |
			instr applySubstitutions: substitutionDictionary
		]
	].

	newBlocks do: [:each | each computeSuccessors].
	newBlocks do: [:each | each addUnreachableStructuredSuccessors].

	"Only change the returns when we are having a continuation"
	continuationBlock ifNil: [ ^ { newBlocks first . nil } ].

	"Transform the return into jumps".
	sourceFunction functionType returnType isVoidType ifTrue: [ 
		newBlocks do: [:bb |
			bb lastInstruction isReturnVoid ifTrue: [
				bb lastInstruction removeFromBlock.
				bb add: (SLVMJump destination: continuationBlock)
			]
		].
	
		^ {newBlocks first . nil}
	] ifFalse: [
		resultPhi := nil.
		newBlocks do: [:bb |
			return := bb lastInstruction.
			return isReturn ifTrue: [
				resultPhi ifNil: [
					resultPhi := (SLVMPhi type: return value type) name: nil.
					continuationBlock addFirst: resultPhi
				].
		
				resultPhi addValue: return value from: bb.
				bb lastInstruction removeFromBlock.
				bb add: ((SLVMJump destination: continuationBlock) name: nil)
			]
		].
	
		(resultPhi isNil or: [ resultPhi parameters size = 0 ]) ifTrue: [
			"Undefined result"
			self halt.
		].
	
		resultPhi parameters size = 1 ifTrue: [
			result := resultPhi parameters first.
			resultPhi removeFromBlock.
			^ {newBlocks first . result}
		].
	
		^ {newBlocks first . resultPhi}
	]
]

{ #category : #'as yet unclassified' }
SLVMFunction >> createPublicInterfaceDeclarationVersionIn: targetModule [
	| resultFunction |
	self isPubliclyExported ifFalse: [ ^ self ].
	resultFunction := self class module: targetModule name: name functionType: (targetModule importType: functionType fromModule: module).
	resultFunction makeExternal.
	resultFunction flags: self flags copy.
	arguments doWithIndex: [ :arg :index |
		arg createPublicInterfaceVersionIn: (resultFunction arguments at: index)
	].

	module symbolMapToHighLevel at: name ifPresent: [ :highLevelEntity |
		targetModule addHighLevelEntity: highLevelEntity mapToGlobalValue: resultFunction 
	].

	^ resultFunction
]

{ #category : #'as yet unclassified' }
SLVMFunction >> debugType [
	^ self propertyAt: #debugType ifAbsent: [ self functionType ]
]

{ #category : #'as yet unclassified' }
SLVMFunction >> debugType: debugType [
	self propertyAt: #debugType put: debugType
]

{ #category : #'as yet unclassified' }
SLVMFunction >> decodeBasicBlocksFromSExpressions: encodedBasicBlocks [
	| allDecodedInstructions |
	encodedBasicBlocks ifEmpty: [ ^ self ].
	allDecodedInstructions := OrderedCollection new.
	self localValuesDo: [ :each | allDecodedInstructions add: each ].
	
	"First pass: Allocate the elements."
	encodedBasicBlocks do: [ :encodedBB |
		| basicBlock |
		basicBlock := SLVMBasicBlock new.
		basicBlocks add: basicBlock.
		
		encodedBB allButFirstDo: [ :eachInstruction |
			|instruction |
			instruction := (SLVMValue valueClassFromMnemonic: eachInstruction second) new.
			instruction
				createdWithMnemonic: eachInstruction second decodedType: (module decodeSExpressionType: eachInstruction third).
			allDecodedInstructions add: instruction.
			basicBlock addLast: instruction.
		]
	].

	"Second pass: Decode and fixup the pointers."
	encodedBasicBlocks doWithIndex: [ :encodedBB :index |
		| basicBlock instructionIndex |
		basicBlock := basicBlocks at: index.
		instructionIndex := 2.
		basicBlock instructionsDo: [ :instruction |
			| encodedInstruction |
			encodedInstruction := encodedBB at: instructionIndex.
			instruction parameters: (encodedInstruction fifth collect: [:each |
				each first = #local ifTrue: [self . allDecodedInstructions at: each second]
					ifFalse: [module decodeSExpressionValue: each]]).
			instruction decodeFromSExpression: encodedInstruction context: module.
			instructionIndex := instructionIndex + 1
		]
	].
]

{ #category : #'as yet unclassified' }
SLVMFunction >> decodeDeclarationFromSExpression: encodedGlobal context: context [
	| callingConvention returnType dict encodedArguments argumentTypes variadic decodedFunctionType |
	name := encodedGlobal third.
	callingConvention := encodedGlobal fourth.
	returnType := (context decodeSExpressionType: encodedGlobal fifth).
	dict := Dictionary newFromPairs: (encodedGlobal allButFirst: 6).
	encodedArguments := dict at: #arguments ifAbsent: [ #() ].
	variadic := dict at: #variadic ifAbsent: [ false ].
	argumentTypes := encodedArguments collect: [ :arg | context decodeSExpressionType: arg second].
	
	decodedFunctionType := (SLVMFunctionType callingConvention: callingConvention arguments: argumentTypes returnType: returnType)
		variadic: variadic;
		yourself.
	self pointerSize: context compilationTarget pointerSize functionType: decodedFunctionType.
	self decodeGlobalValueAttributesFromSExpression: encodedGlobal sixth context: context.

]

{ #category : #'as yet unclassified' }
SLVMFunction >> decodeDefinitionFromSExpression: encodedGlobal context: context [
	| dict argDefinitions literalDefinitions |
	self assert: context == module.
	dict := Dictionary newFromPairs: (encodedGlobal allButFirst: 6).
	argDefinitions := dict at: #arguments ifAbsent: [ #() ].
	argDefinitions doWithIndex: [ :argDefinition :index |
		(arguments at: index) decodeFromSExpression: argDefinition context: context
	].

	literalDefinitions := dict at: #literals ifAbsent: [ #() ].
	literalDefinitions do: [ :literals |
		self halt
	].

	self decodeBasicBlocksFromSExpressions: (dict at: #blocks).
]

{ #category : #testing }
SLVMFunction >> doesHaveMultipleReturns [
	^ self hasFlag: #returns_twice
]

{ #category : #testing }
SLVMFunction >> doesHaveMultipleReturns: value [
	^ self setFlag: #returns_twice value: value
]

{ #category : #'control flow' }
SLVMFunction >> dominanceTopoSort [
	| visited result |
	self computeDominance.
	self computeBackEdges.
	visited := Set new.
	result := OrderedCollection new.
	basicBlocks do: [ :node | self dominanceTopoSort: node visitedSet: visited destination: result ].

	^ result
]

{ #category : #'control flow' }
SLVMFunction >> dominanceTopoSort: node visitedSet: visitedSet destination: destination [
	node ifNil: [ ^ self ].
	(visitedSet includes: node) ifTrue: [ ^ self ].
	visitedSet add: node.
	
	"Add the immediate dominator"
	self dominanceTopoSort: node immediateDominator visitedSet: visitedSet destination: destination.

	"Add the predecessors that are not back edges"
	node predecessors do: [ :pred |
		(node isBackEdgeToMe: pred) ifFalse: [ 
			self dominanceTopoSort: pred visitedSet: visitedSet destination: destination
		]
	].

	"Add the node"
	destination add: node.

]

{ #category : #'control flow' }
SLVMFunction >> dominances: doms intersect: n1 with: n2 [
	| finger1 finger2 |
	finger1 := n1.
	finger2 := n2.
	[ finger1 ~= finger2 ] whileTrue: [
		[ finger1 < finger2 ] whileTrue: [
			finger1 := doms at: finger1.
		].
		[ finger2 < finger1 ] whileTrue: [
			finger2 := doms at: finger2.
		]
	].

	^ finger1
]

{ #category : #accessing }
SLVMFunction >> dynamicLiterals [
	^ dynamicLiterals
]

{ #category : #'control flow' }
SLVMFunction >> ensureCanonicalStructuredControlFlow [
	"Inlining requires a canonical structured control flow in order to
	preserve the invariants for structured control flow."
	(self canHaveCanonicalStructuredControlFlow and: [ self hasCanonicalStructuredControlFlow not ]) ifTrue: [
		SLVMOptCanonicalizeStructuredControlFlow passOnFunction: self
	]
]

{ #category : #accessing }
SLVMFunction >> exitPoint [
	<compileTime>
	^ SLVMConstantFunctionExitPoint new
		type: compilationTarget voidPointerType;
		sourceMethod: self
]

{ #category : #printing }
SLVMFunction >> fullPrintOn: aStream [
	aStream putIdentifier: ('@', (name ifNil: [#anonymous])); space; print: type; cr.
	dynamicLiterals ifNotEmpty: [
		aStream putKeyword: #literals; nextPutAll: ' ['; cr.
		dynamicLiterals do: [ :lit | aStream print: lit value; cr ].
		aStream nextPutAll: ']'; cr.
	].

	aStream nextPutAll: '{'; cr.
	basicBlocks do: [ :bb | bb fullPrintOn: aStream ].
	aStream nextPutAll: '}'; cr.
]

{ #category : #accessing }
SLVMFunction >> functionType [
	^ functionType
]

{ #category : #accessing }
SLVMFunction >> gcStrategy [
	^ self propertyAt: #gcStrategy ifAbsent: [ nil ]
]

{ #category : #accessing }
SLVMFunction >> gcStrategy: aGCStrategyName [
	^ self propertyAt: #gcStrategy put: aGCStrategyName
]

{ #category : #'gt inspector extensions' }
SLVMFunction >> gtTextViewIn: composite [
	<gtInspectorPresentationOrder: 1>
	composite text
		title: 'Text';
		display: [ :node | node fullPrintString ]
]

{ #category : #'gt inspector extensions' }
SLVMFunction >> gtTreeViewIn: composite [
	<gtInspectorPresentationOrder: 0>
	composite tree 
		title: 'Nodes';
		display: [ :node | node ];
		children: [ :each | each childrenNodes];
		format: [ :node | node nodeTitle ]
]

{ #category : #inlining }
SLVMFunction >> hasAlwaysInlineMode [
	^ self inlineMode == #always
]

{ #category : #'control flow' }
SLVMFunction >> hasCanonicalStructuredControlFlow [
	^ self propertyAt: #hasCanonicalStructuredControlFlow ifAbsent: [ false ]
]

{ #category : #'control flow' }
SLVMFunction >> hasCanonicalStructuredControlFlow: aBoolean [
	^ self propertyAt: #hasCanonicalStructuredControlFlow put: aBoolean
]

{ #category : #inlining }
SLVMFunction >> hasNeverInlineMode [
	^ self inlineMode == #never
]

{ #category : #inlining }
SLVMFunction >> hasNoInlineMode [
	^ self inlineMode == false
]

{ #category : #testing }
SLVMFunction >> hasSelectorAndClassBinding [
	^ self propertyAt: #selectorAndClassBinding ifAbsent: [ false ]
]

{ #category : #testing }
SLVMFunction >> hasSelectorAndClassBinding: aBoolean [
	^ self propertyAt: #selectorAndClassBinding put: aBoolean
]

{ #category : #testing }
SLVMFunction >> hasStructReturnPointer [
	^ arguments isNotEmpty and: [ arguments first isStructReturnPointer ]
]

{ #category : #inlining }
SLVMFunction >> hasYesInlineMode [
	^ self inlineMode == true
]

{ #category : #initialization }
SLVMFunction >> initialize [
	super initialize.
	localValueIndexComputationCount := 0.
	basicBlocks := OrderedCollection new.
	dynamicLiterals := OrderedCollection new.
	arguments := #().
	haveDominance := false.
	needsCompiledMethodObject := false.
]

{ #category : #inlining }
SLVMFunction >> inlineMode [
	^ self propertyAt: #inlineMode ifAbsent: [ false ]
]

{ #category : #inlining }
SLVMFunction >> inlineMode: anInlineMode [
	self assert: (#(false true always never) includes: anInlineMode).
	^ self propertyAt: #inlineMode put: anInlineMode
]

{ #category : #printing }
SLVMFunction >> instructionsSExpressions [
	^ basicBlocks collect: [ :each | each asFullSExpression ] as: Array
]

{ #category : #'control flow' }
SLVMFunction >> invalidateControlFlowCaches [
	preOrder := nil.
	postOrder := nil.
	haveDominance := false.
]

{ #category : #'as yet unclassified' }
SLVMFunction >> invalidateLocalValueIndices [
	localValueIndexComputationCount := localValueIndexComputationCount + 1
]

{ #category : #testing }
SLVMFunction >> isEmpty [
	^ basicBlocks isEmpty
]

{ #category : #testing }
SLVMFunction >> isFunction [
	^ true
]

{ #category : #testing }
SLVMFunction >> isNoReturn [
	^ self hasFlag: #noreturn
]

{ #category : #testing }
SLVMFunction >> isNoUnwind [
	^ self hasFlag: #nounwind
]

{ #category : #testing }
SLVMFunction >> isNotEmpty [
	^ self isEmpty not
]

{ #category : #accessing }
SLVMFunction >> localValueIndexComputationCount [
	^ localValueIndexComputationCount
]

{ #category : #enumerating }
SLVMFunction >> localValuesDo: aBlock [
	arguments do: aBlock.
	dynamicLiterals do: aBlock.
	basicBlocks do: [ :bb |
		bb instructionsDo: aBlock
	].
]

{ #category : #private }
SLVMFunction >> makeArguments [
	arguments := functionType arguments collectWithIndex: [ :argType :index |
		SLVMFunctionArgument new
			function: self;
			type: argType;
			index: index;
			yourself
	]
]

{ #category : #accessing }
SLVMFunction >> needsCompiledMethodObject [
	^ needsCompiledMethodObject
]

{ #category : #accessing }
SLVMFunction >> needsCompiledMethodObject: aBoolean [
	needsCompiledMethodObject := aBoolean
]

{ #category : #accessing }
SLVMFunction >> personalityFunction [
	^ personalityFunction
]

{ #category : #accessing }
SLVMFunction >> personalityFunction: anObject [
	personalityFunction := anObject
]

{ #category : #accessing }
SLVMFunction >> pointerSize: pointerSize functionType: aFunctionType [
	self assert: aFunctionType isSlovimType.
	functionType := aFunctionType.
	type := SLVMPointerType size: pointerSize baseType: functionType storage: SLVMType genericStorage.
	self makeArguments.
]

{ #category : #'control flow' }
SLVMFunction >> postOrder [
	| visited |
	postOrder ifNotNil: [ ^ postOrder ].
	visited := Array new: basicBlocks size withAll: false.
	postOrder := OrderedCollection new.
	self computePostOrderFor: basicBlocks first visited: visited.
	^ postOrder
]

{ #category : #'control flow' }
SLVMFunction >> preOrder [
	| visited |
	preOrder ifNotNil: [ ^ preOrder ].
	visited := Array new: basicBlocks size withAll: false.
	preOrder := OrderedCollection new.
	self computePreOrderFor: basicBlocks first visited: visited.
	^ preOrder
]

{ #category : #printing }
SLVMFunction >> prettyPrintBlockSExpression: blockSExpression into: output [
	output tab; tab; nextPut: $(; print: blockSExpression first; cr.
	blockSExpression allButFirstDo: [ :instruction |
		output tab; tab; tab; print: instruction; cr.
	].
	output tab; tab; nextPut: $); cr.
]

{ #category : #accessing }
SLVMFunction >> primitive [
	<compileTime>
	^ self propertyAt: #primitive ifAbsent: [ nil ]
]

{ #category : #accessing }
SLVMFunction >> primitive: aPrimitive [
	^ self propertyAt: #primitive put: aPrimitive
]

{ #category : #'as yet unclassified' }
SLVMFunction >> recomputeLocalValueIndices [
	| index |
	index := 0.
	self localValuesDo: [ :localValue |
		localValue
			localValueIndex: index;
			localValueIndexComputationCount: localValueIndexComputationCount.
		index := index + 1
	].
]

{ #category : #removing }
SLVMFunction >> removeBasicBlock: aBasicBlock [
	basicBlocks remove: aBasicBlock.
	aBasicBlock function: nil.
	self invalidateControlFlowCaches.
	basicBlocks doWithIndex: [ :bb :index | bb index: index ]
]

{ #category : #removing }
SLVMFunction >> removeRuntimeLiterals [
	| result |
	dynamicLiterals ifEmpty: [ ^ #() ].
	
	result := dynamicLiterals last: 2.
	dynamicLiterals := dynamicLiterals allButLast: 2.
	^ result
]

{ #category : #accessing }
SLVMFunction >> returnType [
	^ functionType returnType
]

{ #category : #testing }
SLVMFunction >> selectorValue [
	^ (dynamicLiterals at: dynamicLiterals size - 1) value
]

{ #category : #testing }
SLVMFunction >> setNoReturn: value [
	^ self setFlag: #noreturn value: value
]

{ #category : #testing }
SLVMFunction >> setNoUnwind: value [
	^ self setFlag: #nounwind value: value
]

{ #category : #accessing }
SLVMFunction >> type [
	^ type
]

{ #category : #'development support' }
SLVMFunction >> validate [
	basicBlocks do: [ :bb |
		self assert: bb function == self.
		self assert: bb isLastTerminator.
		
		bb instructionsDo: [ :instruction |
			instruction validateInBlock: bb
		].
	
		bb successors do: [ :succ |
			self assert: (basicBlocks includes: succ).
		].
		bb predecessors do: [ :pred |
			self assert: (basicBlocks includes: pred).
		].

	]
]

"
I provide common processes for translating a Slovim module into a high-level language such as C, GLSL, HLSL or Javascript.
"
Class {
	#name : #SLVMHighLevelLanguageCodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'typeDeclarations',
		'globalVariableDeclarations',
		'functionDefinitions',
		'translatedValueDictionary',
		'outputStream',
		'indentationLevel',
		'gensymCount',
		'deferredBlocks',
		'currentStatementList',
		'continueBlock',
		'breakBlock',
		'currentFunctionNode',
		'usedLocalSymbols',
		'translatedBlocks',
		'phiVariableDictionary'
	],
	#classVars : [
		'BuiltInFunctionMap'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #'class initialization' }
SLVMHighLevelLanguageCodeGenerator class >> initialize [
	super initialize.
	BuiltInFunctionMap := Dictionary newFromPairs: #(
		'binop.add'		(+ binary)
		'binop.sub'   (- binary)
		'binop.mul'   (* binary)
		'binop.div'   (/ binary)
		'binop.udiv'  (/ binary)
		'binop.rem'   (% binary)
		'binop.urem'  (% binary)

		'binop.bitand' (& binary)
		'binop.bitor' (| binary)
		'binop.bitxor' (^ binary)

		'binop.shiftleft' (<< binary)
		'binop.shiftright' (>> binary)

		'binop.ilt' (< binary)
		'binop.ile' (<= binary)
		'binop.ieq' (== binary)
		'binop.ine' (!= binary)
		'binop.igt' (> binary)
		'binop.ige' (>= binary)

		'binop.fadd' 		(+ binary)
		'binop.fsub' 		(- binary)
		'binop.fmul' 		(* binary)
		'binop.fdiv' 		(/ binary)
		'binop.frem' 		(% binary)

		'binop.uflt' (< binary)
		'binop.ufle' (<= binary)
		'binop.ufeq' (== binary)
		'binop.ufne' (!= binary)
		'binop.ufgt' (> binary)
		'binop.ufge' (>= binary)

		'binop.oflt' (< binary)
		'binop.ofle' (<= binary)
		'binop.ofeq' (== binary)
		'binop.ofne' (!= binary)
		'binop.ofgt' (> binary)
		'binop.ofge' (>= binary)
		
		'binop.mulMatrixMatrix' (* binary)
		'binop.mulMatrixVector' (* binary)
		'binop.mulVectorMatrix' (* binary)
		
		'unary.neg'		(- unary)
		'unary.not'   (~ unary)
		'unary.lnot'  (! unary)
		'unary.fneg'   (- unary)
		
		'sample.implicit_lod' (sampleImplicitLod call)
		
		#'math.acos'	(#'acos' call)
		#'math.acosh'	(#'acosh' call)
		#'math.asin'	(#'asin' call)
		#'math.asinh'	(#'asinh' call)
		#'math.atan2'	(#'atan2' call)
		#'math.atan'	(#'atan' call)
		#'math.atanh'	(#'atanh' function)
		#'math.ceil'	(#'ceil' function)
		#'math.cos'     (#'cos' function)
		#'math.cosh'	(#'cosh' call)
		#'math.degrees'	(#'degrees' call)
		#'math.exp2'	(#'exp2' call)
		#'math.exp'     (#'exp' call)
		#'math.fabs'	(#'abs' call)
		#'math.floor'	(#'floor' call)
		#'math.fmax'	(#'max' call)
		#'math.fmin'	(#'min' call)
		#'math.fmix'	(#'mix' call)
		#'math.fract'	(#'fract' call)
		#'math.fsign'	(#'fsign' call)
		#'math.inverseSqrt'	(#'inverseSqrt' call)
		#'math.log2'	(#'log2' call)
		#'math.log'	    (#'log' call)
		#'math.pow'     (#'pow' call)
		#'math.radians'	(#'radians' call)
		#'math.roundEven'	(#'roundEven' call)
		#'math.round'	(#'round' call)
		#'math.sinh'	(#'sinh' call)
		#'math.sin'     (#'sin' call)
		#'math.smax'	(#'max' call)
		#'math.smin'	(#'min' call)
		#'math.smoothstep'	(#'smoothstep' call)
		#'math.sqrt'	(#'sqrt' call)
		#'math.step'	(#'step' call)
		#'math.tan'	(#'tan' call)
		#'math.trunc'	(#'trunc' call)
		#'math.umax'	(#'max' call)
		#'math.umin'	(#'min' call)
		#'matrix.transpose'	(#'transpose' call)
		#'vector.cross'     (#'cross' call)
		#'vector.dot'	    (#'dot' call)
		#'vector.length'	(#'length' call)
		#'vector.normalize'	(#'normalize' call)
		#'vector.reflect'	(#'reflect' call)
		#'vector.refract'	(#'refract' call)

	)
]

{ #category : #adding }
SLVMHighLevelLanguageCodeGenerator >> addStatement: aStatement [
	currentStatementList add: aStatement
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> addSuccessorsPhi: instruction [
	| currentBlock sourceValueSet destValueSet sourceDestMap copyValue variable copyStatement intersection tempBeforeCopies tempVar |
	currentBlock := instruction block.
	sourceValueSet := Set new.
	destValueSet := Set new.
	sourceDestMap := OrderedCollection new.
	
	"TODO: Ensure the copies are actually made in parallel."
	instruction successors do: [ :succ |
		succ phiInstructionsDo: [ :phi |
			phi valuesAndParentsDo: [ :value :parent |
				parent == currentBlock ifTrue: [
					sourceValueSet add: value.
					destValueSet add: phi.
					sourceDestMap add: value -> phi.
				]
			]
		]
	].

	tempBeforeCopies := Dictionary new.
	intersection := sourceValueSet intersection: destValueSet.
	intersection do: [ :value |
		copyValue := self translateValue: value.
		tempVar := self generateTemp: (self translateType: value type).
		copyStatement := SLVMHLVariableAssignmentStatement new
			variable: tempVar;
			value: copyValue.
		self addStatement: copyStatement.
		tempBeforeCopies at: value put: tempVar
	].

	sourceDestMap do: [ :sourceAndDest |
		copyValue := tempBeforeCopies at: sourceAndDest key ifAbsent: [ self translateValue: sourceAndDest key ].
		variable := self translateValue: sourceAndDest value. 
		copyStatement := SLVMHLVariableAssignmentStatement new
			variable: variable;
			value: copyValue.
		self addStatement: copyStatement
	]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> decreaseIndentationLevel [
	indentationLevel := indentationLevel - 1.
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> deferBlockCount: aBasicBlock [
	aBasicBlock ifNil: [ -1 ].
	^ deferredBlocks at: aBasicBlock ifAbsent: [ 0 ]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> deferBlockTranslation: aBasicBlock [
	| count |
	aBasicBlock ifNil: [ ^ self ].
	count := deferredBlocks at: aBasicBlock ifAbsent: [ 0 ].
	deferredBlocks at: aBasicBlock put: count + 1
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> emitBlockStatementList: statementList [
	statementList statements ifEmpty: [
		^ self withExtraIndentationLevel: [ self emitLine: ';' ].
	].
 
	(statementList statements size = 1 and: [ statementList statements first isIfStatement not ]) ifTrue: [ 
		self withExtraIndentationLevel: [ statementList translateWith: self ].
	] ifFalse: [ 
		self
			emitLine: '{';
			withExtraIndentationLevel: [ statementList translateWith: self ];
			emitLine: '}'
	]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> emitLine: aString [
	self
		emitTabs;
		emitString: aString;
		emitNewline
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> emitNewline [
	outputStream lf
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> emitPrelude [

]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> emitString: aString [
	outputStream nextPutAll: aString
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> emitTabs [
	1 to: indentationLevel do: [ :i | outputStream tab ]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> emitTranslatedCode: nodes [
	^ ByteString streamContents: [ :out |
		outputStream := out.
		self emitPrelude.
		nodes do: [ :node |
			node translateWith: self
		]
	]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> functionTranslation: value do: aBlock [
	| hlNode |
	^ translatedValueDictionary at: value ifAbsent: [
		hlNode := SLVMHLFunctionNode new.
		translatedValueDictionary at: value put: hlNode.
		aBlock value: hlNode.
		functionDefinitions add: hlNode.
		hlNode
	]
]

{ #category : #private }
SLVMHighLevelLanguageCodeGenerator >> generateSymbol [
	gensymCount := gensymCount + 1.
	^ ('_g', gensymCount asString) asSymbol
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> generateTemp: rawType [
	| type temp |
	type := self translateType: rawType.
	temp := SLVMHLVariableDeclNode new type: type; name: self generateSymbol.
	currentFunctionNode locals add: temp.
	^ temp
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> globalValueTranslation: value do: aBlock [
	| hlNode |
	^ translatedValueDictionary at: value ifAbsentPut: [
		hlNode := aBlock value.
		globalVariableDeclarations add: hlNode.
		hlNode
	]
]

{ #category : #testing }
SLVMHighLevelLanguageCodeGenerator >> hasFunctionOverloadingSupport [
	^ true
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> increaseIndentationLevel [
	indentationLevel := indentationLevel + 1.
]

{ #category : #initialization }
SLVMHighLevelLanguageCodeGenerator >> initialize [
	super initialize.
	indentationLevel := 0.
	gensymCount := 0.
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> instructionTranslation: value allocate: allocateBlock do: aBlock [
	| translatedValue |
	^ translatedValueDictionary at: value ifAbsent: [ 
		translatedValue := allocateBlock value.
		translatedValueDictionary at: value put: translatedValue.
		aBlock value: translatedValue
	]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> instructionWithResultTranslation: instruction allocate: allocateBlock do: aBlock [
	instruction type isVoidType ifTrue: [
		^ self instructionTranslation: instruction allocate: allocateBlock do: [:node |
			aBlock value: node.
			self addStatement: node.
		]
	].

	self instructionTranslation: instruction allocate: [ SLVMHLVariableAssignmentStatement new ] do: [ :assignment |
		assignment
			variable: (self generateTemp: instruction type);
			value: allocateBlock value.
			
		aBlock value: assignment value.
		self addStatement: assignment.
	]
]

{ #category : #testing }
SLVMHighLevelLanguageCodeGenerator >> isAbstract [
	^ self == SLVMHighLevelLanguageCodeGenerator
]

{ #category : #testing }
SLVMHighLevelLanguageCodeGenerator >> isAddingStructureKindName [
	^ true
]

{ #category : #testing }
SLVMHighLevelLanguageCodeGenerator >> isBlackListedSymbol: aSymbol [
	^ false
]

{ #category : #testing }
SLVMHighLevelLanguageCodeGenerator >> isValidSymbol: aSymbol [
	(aSymbol isNil or: [aSymbol isEmpty]) ifTrue: [ ^ false ].
	aSymbol do: [ :char | (self isValidSymbolCharacter: char) ifFalse: [ ^ false ]].
	^ true
]

{ #category : #testing }
SLVMHighLevelLanguageCodeGenerator >> isValidSymbolCharacter: char [
	^ (char >= $a and: [ char <= $z ]) or: [
		(char >= $A and: [ char <= $Z ]) or: [
		(char >= $0 and: [ char <= $9 ]) or: [
		char = $_]]]
		
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> makeFunctionPrototypeString: function [
	| functionType |
	^ ByteString streamContents: [:out |
		functionType := function type.
		out
			nextPutAll: functionType returnType name; space;
			nextPutAll: function name; space; nextPut: $(.
		function arguments doWithIndex: [ :arg :index |
			index > 1 ifTrue: [ out nextPutAll: ', ' ].
			out nextPutAll: arg type name; space; nextPutAll: arg name
		].
	
		out nextPut: $)
	]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> mapBuiltInFunction: aFunctionName [
	^ BuiltInFunctionMap at: aFunctionName
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> pureInstructionTranslation: instruction allocate: allocateBlock do: aBlock [
	instruction instructionReferences size <= 1 ifTrue: [
		^ self instructionTranslation: instruction allocate: allocateBlock do: aBlock
	].

	self instructionWithResultTranslation: instruction allocate: allocateBlock do: aBlock

]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateArrayType: type [
	| baseType |
	baseType := self translateType: type baseType.
	^ SLVMHLArrayTypeNode new baseType: baseType; elements: type elements; name: baseType name; yourself
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> translateBasicBlock: aBasicBlock [
	aBasicBlock == continueBlock ifTrue: [ 
		self addStatement: SLVMHLContinueStatement new.
		^ self
	].
	aBasicBlock == breakBlock ifTrue: [ 
		self addStatement: SLVMHLBreakStatement new.
		^ self
	].

	(self deferBlockCount: aBasicBlock) > 0 ifTrue: [ ^ self ].
	(translatedBlocks includes: aBasicBlock) ifTrue: [ ^ self ].
	translatedBlocks add: aBasicBlock.
	aBasicBlock instructionsDo: [ :instruction | instruction accept: self ].
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateBasicType: aType [
	^ SLVMHLBasicTypeNode new name: (self translateBasicTypeName: aType); type: aType
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateBasicTypeName: aType [
	^ aType name
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> translateFunction: function contentInto: functionNode [
	| oldDeferredBlocks oldFunctionNode oldTranslatedBlocks oldUsedLocalSymbols oldPhiVariableDictionary |
	oldDeferredBlocks := deferredBlocks.
	oldFunctionNode := currentFunctionNode.
	oldUsedLocalSymbols := usedLocalSymbols.
	oldTranslatedBlocks := translatedBlocks.
	oldPhiVariableDictionary := phiVariableDictionary.
	[
		deferredBlocks := Dictionary new.
		usedLocalSymbols := Set new.
		translatedBlocks := Set new.
		phiVariableDictionary := Dictionary new.
		currentFunctionNode := functionNode.
		functionNode body: SLVMHLStatementList new.
		self withStatementList: functionNode body do: [
			self translateBasicBlock: function basicBlocks first.
		].
	
		functionNode body removeFinalReturnVoids.
	] ensure: [
		deferredBlocks := oldDeferredBlocks.
		currentFunctionNode := oldFunctionNode.
		usedLocalSymbols := oldUsedLocalSymbols.
		translatedBlocks := oldTranslatedBlocks.
		phiVariableDictionary := oldPhiVariableDictionary
	]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateFunctionArgument: arg [
	| argNode |
	argNode := SLVMHLFunctionArgumentNode new
		name: (self translateSymbol: arg name);
		type: (self translateType: arg type).
	translatedValueDictionary at: arg put: argNode.
	^ argNode
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateFunctionType: functionType [
	| returnType arguments |
	returnType := self translateType: functionType returnType.
	arguments := functionType arguments collect: [ :arg | self translateType: arg ].
	^ SLVMHLFunctionTypeNode new returnType: returnType; arguments: arguments; yourself
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLBreakStatement: statement [
	self
		emitLine: 'break;'
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLBuiltInCallStatementValue: statement [
	| mappedFunction functionName functionType |
	mappedFunction := self mapBuiltInFunction: statement function.
	functionName := mappedFunction first.
	functionType := mappedFunction second.
	 
	functionType == #binary ifTrue: [
		^ ByteString streamContents: [ :out |
		
			out
				nextPut: $(;
				nextPutAll: (statement arguments first translateValueWith: self);
				space;
				nextPutAll: functionName;
				space;
				nextPutAll: (statement arguments second translateValueWith: self);
				nextPut: $)
		]
	].

	functionType == #unary ifTrue: [ 
		^ ByteString streamContents: [ :out |
		
			out
				nextPutAll: functionName;
				nextPutAll: (statement arguments first translateValueWith: self).
		]
	].

	^ ByteString streamContents: [ :out |
		
		out nextPutAll: functionName.
		out nextPut: $(.
		statement arguments doWithIndex: [ :arg :index |
			index > 1 ifTrue: [ out nextPutAll: ', ' ].
			out nextPutAll: (arg translateValueWith: self)
		].
	
		out nextPut: $).
	]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLBuiltInFunctionValue: function [
	^ function name
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLCallStatement: statement [
	self emitTabs; emitString: (self translateHLCallStatementValue: statement); emitString: ';'; emitNewline.
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLCallStatementValue: statement [
	^ ByteString streamContents: [ :out |
		out nextPutAll: (statement function translateValueWith: self).
		out nextPut: $(.
		statement arguments doWithIndex: [ :arg :index |
			index > 1 ifTrue: [ out nextPutAll: ', ' ].
			out nextPutAll: (arg translateValueWith: self)
		].
	
		out nextPut: $).
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> translateHLCombineSamplerWithTexture: combine [
	^ ByteString streamContents: [ :out |
		out nextPutAll: combine combinedType name;
			nextPut: $(;
			nextPutAll: (combine texture translateValueWith: self);
			nextPut: $,;
			space;
			nextPutAll: (combine sampler translateValueWith: self);
			nextPut: $).
	]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLConstructComposite: composite [
	^ ByteString streamContents: [ :out |
		out nextPutAll: composite type name; nextPut: $(.
		composite arguments doWithIndex: [ :arg :index |
			index > 1 ifTrue: [ out nextPutAll: ', ' ].
			out nextPutAll: (arg translateValueWith: self).
		].
		out nextPut: $)
	]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLContinueStatement: statement [
	self
		emitLine: 'continue;'
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLElementReferenceValue: statement [
	statement isStructureMember ifTrue: [
		^ '{1}.{2}' format: { statement reference translateValueWith: self . statement member name }
	] ifFalse: [ 
		^ '{1}[{2}]' format: { statement reference translateValueWith: self . statement member translateValueWith: self }
	].


]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLFunction: function [
	self
		emitLine: (self makeFunctionPrototypeString: function);
		emitLine: '{';
		withExtraIndentationLevel: [
			function locals do: [ :local | local translateWith: self ].
			function body translateWith: self.
		];
		emitLine: '}';
		emitNewline
		
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLFunctionArgumentNodeValue: argument [
	^ argument name
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLFunctionValue: function [
	^ function name
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLIfStatement: statement [
	(statement trueBody isEmpty and: [ statement falseBody isEmpty ]) ifTrue: [ ^ self ].
	statement trueBody isEmpty ifTrue: [ 
		^ self
			emitLine: ('if (!({1}))' format: {statement condition translateValueWith: self });
			emitBlockStatementList: statement falseBody.
	].

	self
		emitLine: ('if ({1})' format: {statement condition translateValueWith: self });
		emitBlockStatementList: statement trueBody.
		
	statement falseBody isEmpty ifFalse: [
		self
			emitLine: 'else';
			emitBlockStatementList: statement falseBody.
	]	
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLLiteralValue: literalValue [
	^ literalValue value value asString
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLLoadStatementValue: statement [
	^ statement variable translateValueWith: self
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLReturn: statement [
	self emitLine: ('return {1};' format: {statement value translateValueWith: self})
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLReturnVoid: statement [
	self emitLine: 'return;'
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLStatementList: list [
	list statements do: [ :statement | statement translateWith: self ]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLStatementListInline: list [
	^ ByteString streamContents: [:out |
		list statements doWithIndex: [ :statement :index |
			index > 1 ifTrue: [ out nextPutAll: ', ' ].
			out nextPutAll: (statement translateInlineWith: self)
		]
	]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLStructure: structure [
	self
		emitLine: ('struct {1}' format: { structure name });
		emitLine: '{';
		withExtraIndentationLevel: [
			structure fields do: [ :field | self translateHLVariableDecl: field ]
		];
		emitLine: '};';
		emitNewline.
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLUntilLoopStatement: statement [
	statement continueBody ifNotNil: [ 
		self
			emitLine: ('for (;!({1}); {2})' format: {
				statement condition translateValueWith: self .
				statement continueBody translateInlineWith: self});
			emitLine: '{';
			withExtraIndentationLevel: [ statement body translateWith: self ];
			emitLine: '}'
	] ifNil: [ 
		self
			emitLine: ('while (!({1}))' format: {statement condition translateValueWith: self });
			emitLine: '{';
			withExtraIndentationLevel: [ statement body translateWith: self ];
			emitLine: '}'
	]

]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLVariableAssignmentStatement: assignment [
	| value variable |
	value := assignment value translateValueWith: self.
	variable := assignment variable translateValueWith: self.
	self emitLine: ('{1} = {2};' format: {variable . value})
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLVariableAssignmentStatementInline: assignment [
	| value variable |
	value := assignment value translateValueWith: self.
	variable := assignment variable translateValueWith: self.
	^ '{1} = {2}' format: {variable . value}
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLVariableAssignmentStatementValue: assignment [
	^ assignment variable translateValueWith: self
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLVariableDecl: variableDecl [
	| variableType arrayBounds variableTypeString |
	variableType := variableDecl type.
	arrayBounds := variableType arrayBounds.
	variableTypeString := variableType name.

	self emitLine: ('{1} {2}{3};' format: { variableTypeString . variableDecl name . arrayBounds})

]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLVariableDeclValue: variable [
	^ variable name
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLVectorSwizzleValue: swizzle [
	^ ByteString streamContents: [ :out |
		out nextPutAll: (swizzle vector translateValueWith: self).
		out nextPut: $..
		swizzle members do: [ :member |
			member = 0 ifTrue: [ out nextPut: $x ].
			member = 1 ifTrue: [ out nextPut: $y ].
			member = 2 ifTrue: [ out nextPut: $z ].
			member = 3 ifTrue: [ out nextPut: $w ].
		]
	]
	
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateHLWhileLoopStatement: statement [
	statement continueBody ifNotNil: [ 
		self
			emitLine: ('for (;{1}; {2})' format: {
				statement condition translateValueWith: self .
				statement continueBody translateInlineWith: self});
			emitLine: '{';
			withExtraIndentationLevel: [ statement body translateWith: self ];
			emitLine: '}'
	] ifNil: [ 
		self
			emitLine: ('while ({1})' format: {statement condition translateValueWith: self });
			emitLine: '{';
			withExtraIndentationLevel: [ statement body translateWith: self ];
			emitLine: '}'
	]

]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateInstruction: aValue [
	^ translatedValueDictionary at: aValue ifAbsent: [ ^ aValue accept: self ]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> translateLocalSymbol: aSymbol [
	(usedLocalSymbols includes: [ aSymbol ]) ifTrue: [ ^ self generateSymbol ].
	usedLocalSymbols add: aSymbol.
	^ self translateSymbol: aSymbol
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateModule: ssaModule exportList: exportList [
	typeDeclarations := OrderedCollection new.
	globalVariableDeclarations := OrderedCollection new.
	functionDefinitions := OrderedCollection new.
	translatedValueDictionary := Dictionary new.
	
	exportList do: [ :global |
		global accept: self
	].
	^ self emitTranslatedCode: typeDeclarations , globalVariableDeclarations , functionDefinitions
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateReferenceType: type [
	| baseType name |
	baseType := self translateType: type baseType.
	name := baseType name , '&'.
	^ SLVMHLReferenceTypeNode new baseType: baseType; name: name asSymbol; yourself
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateStructureType: type [
	| structure fieldName name |
	^ self typeTranslation: type do: [
		name := type name.
		self isAddingStructureKindName ifTrue: [
			(name isNotNil and: [type kind ~~ SLVMStructureType genericKind ]) ifTrue: [
				name := (name , '_' , type kind)  asString
			].
		].
	
		structure := SLVMHLStructureTypeNode new name: (self translateSymbol: name).
		structure
			kind: type kind; 
			fields: (type types collectWithIndex: [ :fieldType :fieldIndex |
			fieldName := nil.
			type names ifNotNil: [ fieldName := type names at: fieldIndex ].
			SLVMHLStructureTypeFieldNode new
				name: (self translateSymbol: fieldName);
				type: (self translateType: fieldType);
				yourself.
		]).
		structure
	]

]

{ #category : #protocol }
SLVMHighLevelLanguageCodeGenerator >> translateSymbol: aSymbol [
	(self isBlackListedSymbol: aSymbol) ifTrue: [ ^ self generateSymbol ].
	^ (self isValidSymbol: aSymbol) ifTrue: [ aSymbol ] ifFalse: [ self generateSymbol ]
	
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateType: aType [
	aType isStructureType ifTrue: [ ^ self translateStructureType: aType ].
	aType isArrayType ifTrue: [ ^ self translateArrayType: aType ].
	aType isFunctionType ifTrue: [ ^ self translateFunctionType: aType ].
	aType isReferenceType ifTrue: [ ^ self translateReferenceType: aType ]. 
	^ self translateBasicType: aType
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> translateValue: aValue [
	aValue isInstruction ifTrue: [ ^ self translateInstruction: aValue ].
	^ translatedValueDictionary at: aValue ifAbsentPut: [ aValue accept: self ]
]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> typeTranslation: value do: aBlock [
	| hlNode |
	^ translatedValueDictionary at: value ifAbsentPut: [
		hlNode := aBlock value.
		typeDeclarations add: hlNode.
		hlNode
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> undeferBlockTranslation: aBasicBlock [
	| count |
	aBasicBlock ifNil: [ ^ self ].
	count := deferredBlocks at: aBasicBlock ifAbsent: [ 0 ].
	deferredBlocks at: aBasicBlock put: count - 1
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitAlloca: instruction [
	| name type |
	^ self instructionTranslation: instruction allocate: [ SLVMHLVariableDeclNode new ] do: [:variable |
		name := self translateLocalSymbol: instruction name.
		type := self translateType: instruction valueType.

		variable
			name: name;
			type: type.
		currentFunctionNode locals add: variable
	]

]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitBinaryOperation: instruction [
	^ self pureInstructionTranslation: instruction allocate: [ SLVMHLBuiltInCallStatement new ] do: [ :node |
		node
			function: ('binop.', instruction operation) asSymbol;
			arguments: { self translateValue: instruction left . self translateValue: instruction right}
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitBranch: branch [
	| trueList falseList statement isLoop condition continueList |
	self addSuccessorsPhi: branch.
	self withBranchBlocks: branch do: [
		isLoop := branch continueBlock isNotNil.
		condition := self translateValue: branch condition.
		
		isLoop ifTrue: [ 
			(branch trueBlock == breakBlock and: [ branch falseBlock == breakBlock ]) ifTrue: [ 
				"Useless loop"
				^ self
			].
		
			branch trueBlock == breakBlock ifTrue: [
				"Until loop"
				falseList := SLVMHLStatementList new.
				self withStatementList: falseList do: [ 
					self translateBasicBlock: branch falseBlock
				].
			
				statement := SLVMHLUntilLoopStatement new
					condition: condition;
					body: falseList.
				self addStatement: statement.
			] ifFalse: [
				branch falseBlock == breakBlock ifTrue: [
					"While loop"
					trueList := SLVMHLStatementList new.
					self withStatementList: trueList do: [ 
						self translateBasicBlock: branch trueBlock
					].
				
					statement := SLVMHLWhileLoopStatement new
						condition: condition;
						body: trueList.
					self addStatement: statement.
				] ifFalse: [
					"Infinite loop with if inside"
					self halt.
				]
			]
		] ifFalse: [
	
			trueList := SLVMHLStatementList new.
			self withStatementList: trueList do: [ 
				self translateBasicBlock: branch trueBlock
			].
	
			falseList := SLVMHLStatementList new.
			self withStatementList: falseList do: [ 
				self translateBasicBlock: branch falseBlock
			].
		
			statement:= SLVMHLIfStatement new 
				condition: condition;
				trueBody: trueList;
				falseBody: falseList.
			self addStatement: statement.
		]
	].

	(branch continueBlock isNotNil and:
	[ (translatedBlocks includes: branch continueBlock) not and:
	[ (self deferBlockCount: branch continueBlock) = 0]]) ifTrue: [
		continueList := SLVMHLStatementList new.
		self withStatementList: continueList do: [ 
			self translateBasicBlock: branch continueBlock
		].
		statement continueBody: continueList
	].

	branch continueBlock ifNotNil: [ statement removeFinalContinues ]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitCall: instruction [
	instruction functionValue isPureFunction ifTrue: [ 
		^ self pureInstructionTranslation: instruction allocate: [ SLVMHLCallStatement new ] do: [ :node |
			node
				function: (self translateValue: instruction functionValue);
				arguments: (instruction arguments collect: [:arg | self translateValue: arg])
		]
	] ifFalse: [ 
		^ self instructionWithResultTranslation: instruction allocate: [ SLVMHLCallStatement new ] do: [ :node |
			node
				function: (self translateValue: instruction functionValue);
				arguments: (instruction arguments collect: [:arg | self translateValue: arg])
		]
	] 

]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitCombineSamplerWithTexture: instruction [
	^ self pureInstructionTranslation: instruction allocate: [ SLVMHLCombineSamplerWithTexture new ] do: [ :node |
		node combinedType: (self translateType: instruction type).
		node sampler: (self translateValue: instruction sampler).
		node texture: (self translateValue: instruction texture)
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitConstantBuiltInFunction: aFunction [
	^ SLVMHLBuiltInFunction new name: (self mapBuiltInFunction: aFunction name) first; builtin: aFunction
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitConstantValue: constantValue [
	^ SLVMHLLiteral new value: constantValue
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitExtractVectorElement: instruction [
	instruction index isConstant ifTrue: [ 
		^ self pureInstructionTranslation: instruction allocate: [ SLVMHLVectorSwizzle new ] do: [ :node |
			node vector: (self translateValue: instruction vector).
			node members: {instruction index value}.
		]
	] ifFalse: [ 
		^ self pureInstructionTranslation: instruction allocate: [ SLVMHLElementReference new ] do: [ :node |
			node reference: (self translateValue: instruction vector).
			node member: (self translateValue: instruction index).
		]
	]

]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitFunction: function [
	| functionType name |
	^ self functionTranslation: function do: [ :functionNode |
		functionType := self translateType: function functionType.
		name := nil.
		self hasFunctionOverloadingSupport ifTrue: [ name := function unmangledName ].
		name ifNil: [ name := function name ].
		functionNode
			name: (self translateSymbol: name);
			type: functionType.
		functionNode arguments: (function arguments collect: [ :arg | self translateFunctionArgument: arg ] ).
		
		self translateFunction: function contentInto: functionNode
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitGetElementReference: instruction [
	| baseType index |
	^ self instructionTranslation: instruction allocate: [ SLVMHLElementReference new ] do: [ :node |
		node reference: (self translateValue: instruction reference).
		baseType := (self translateType: instruction reference type baseType).
		index := instruction index.
		(index isConstant and: [ baseType isStructureType ]) ifTrue: [
			node isStructureMember: true.
			node member: (baseType fields at: index value + 1)
		] ifFalse: [
			node isStructureMember: false.
			node member: (self translateValue: index).
		]
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitGlobalVariable: globalVariable [
	| valueType |
	^ self globalValueTranslation: globalVariable do: [
		valueType := self translateType: globalVariable valueType.
		SLVMHLVariableDeclNode new
			name: (self translateSymbol: globalVariable name);
			type: valueType;
			storage: globalVariable type storage;
			definition: globalVariable;
			yourself
	]
	
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitJump: jump [
	| continueList statement |
	self addSuccessorsPhi: jump.
	self withBranchBlocks: jump do: [
		jump continueBlock ifNotNil: [ 
			"TODO: Generate an infinite loop here."
			self halt.
		] ifNil: [
			self translateBasicBlock: jump destination
		]
	].

	(jump continueBlock isNotNil and:
	[ (translatedBlocks includes: jump continueBlock) not and:
	[ (self deferBlockCount: jump continueBlock) = 0]]) ifTrue: [
		continueList := SLVMHLStatementList new.
		self withStatementList: continueList do: [ 
			self translateBasicBlock: jump continueBlock
		].
		statement continueBody: continueList
	].

	jump continueBlock ifNotNil: [ statement removeFinalContinues ]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitLoad: instruction [
	^ self instructionTranslation: instruction allocate: [ SLVMHLLoadStatement new ] do: [ :node |
		node variable: (self translateValue: instruction variable).
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitMakeMatrix: instruction [
	^ self pureInstructionTranslation: instruction allocate: [ SLVMHLConstructComposite new ] do: [ :node |
		node type: (self translateType: instruction type).
		node arguments: (instruction parameters collect: [:arg | self translateValue: arg ]).
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitMakeVector: instruction [
	^ self pureInstructionTranslation: instruction allocate: [ SLVMHLConstructComposite new ] do: [ :node |
		node type: (self translateType: instruction type).
		node arguments: (instruction parameters collect: [:arg | self translateValue: arg ]).
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitPhi: instruction [
	| name type |
	^ self instructionTranslation: instruction allocate: [ SLVMHLVariableDeclNode new ] do: [:variable |
		name := self translateLocalSymbol: instruction name.
		type := self translateType: instruction type.

		variable
			name: name;
			type: type.
		currentFunctionNode locals add: variable.
		phiVariableDictionary at: instruction put: variable
	]

]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitReturn: instruction [
	^ self instructionTranslation: instruction allocate: [ SLVMHLReturnStatement new ] do: [ :node |
		node value: (self translateValue: instruction value).
		self addStatement: node
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitReturnVoid: instruction [
	^ self instructionTranslation: instruction allocate: [ SLVMHLReturnVoidStatement new ] do: [ :node |
		self addStatement: node
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitSampleImplicitLod: instruction [
	^ self pureInstructionTranslation: instruction allocate: [ SLVMHLBuiltInCallStatement new ] do: [ :node |
		node
			function: #'sample.implicit_lod';
			arguments: { self translateValue: instruction sampledTexture . self translateValue: instruction texcoord}
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitShuffleVectors: instruction [
	instruction firstVector == instruction secondVector ifTrue: [ 
		^ self pureInstructionTranslation: instruction allocate: [ SLVMHLVectorSwizzle new ] do: [ :node |
			node vector: (self translateValue: instruction firstVector).
			node members: instruction components.
		]
	] ifFalse: [
		self halt.
	]

]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitStore: instruction [
	^ self instructionTranslation: instruction allocate: [ SLVMHLVariableAssignmentStatement new ] do: [ :node |
		node
			variable: (self translateValue: instruction variable);
			value: (self translateValue: instruction value).
		self addStatement: node.
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> visitUnaryOperation: instruction [
	^ self pureInstructionTranslation: instruction allocate: [ SLVMHLBuiltInCallStatement new ] do: [ :node |
		node
			function: ('unary.', instruction operation) asSymbol;
			arguments: { self translateValue: instruction operand }
	]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> withBranchBlocks: instruction do: aBlock [
	| oldContinueBlock oldBreakBlock |
	self deferBlockTranslation: instruction mergeBlock.
	self deferBlockTranslation: instruction continueBlock.
	
	oldContinueBlock := continueBlock.
	oldBreakBlock := breakBlock.
	(self deferBlockCount: instruction continueBlock) = 1 ifTrue: [
		continueBlock := instruction continueBlock.
		(self deferBlockCount: instruction mergeBlock) = 1 ifTrue: [
			breakBlock := instruction mergeBlock
		].
	].


	aBlock ensure: [
		continueBlock := oldContinueBlock.
		breakBlock := oldBreakBlock.
	
		self undeferBlockTranslation: instruction mergeBlock.
		self undeferBlockTranslation: instruction continueBlock.
		
		instruction mergeBlock ifNotNil: [
			self translateBasicBlock: instruction mergeBlock.
		]
	].

]

{ #category : #'code generation' }
SLVMHighLevelLanguageCodeGenerator >> withExtraIndentationLevel: aBlock [
	self increaseIndentationLevel.
	aBlock ensure: [ self decreaseIndentationLevel ]
]

{ #category : #visitor }
SLVMHighLevelLanguageCodeGenerator >> withStatementList: statementList do: aBlock [
	| oldStatementList |
	oldStatementList := currentStatementList.
	currentStatementList := statementList.
	
	aBlock ensure: [ currentStatementList := oldStatementList ]
]

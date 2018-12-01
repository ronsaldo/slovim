Class {
	#name : #SLVMLLVMBuiltInFunctionGenerator,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#classVars : [
		'BuiltInFunctionDictionary'
	],
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #initialization }
SLVMLLVMBuiltInFunctionGenerator class >> addBuiltIn: builtInName callOverloadedUnary: llvmBuiltInName [
	BuiltInFunctionDictionary at: builtInName put:
		(SLVMLLVMUnaryOverloadedBuiltInFunctionGenerator new
			name: builtInName;
			llvmBuiltIn: llvmBuiltInName;
			yourself)
]

{ #category : #initialization }
SLVMLLVMBuiltInFunctionGenerator class >> addBuiltIn: builtInName inlineWith: aBlock [
	BuiltInFunctionDictionary at: builtInName put:
		(SLVMLLVMInlineBuiltInFunctionGenerator new
			name: builtInName;
			block: aBlock;
			yourself)
]

{ #category : #initialization }
SLVMLLVMBuiltInFunctionGenerator class >> atomicBuiltIn [
	<builtInFunctions>
	self
		addBuiltIn: #'atomic.compare_and_swap' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateAtomicCompare: callInstruction arguments first
				with: callInstruction arguments second
				andSwapWith: callInstruction arguments third
				returnType: callInstruction type
		];
		addBuiltIn: #'atomic.fetch_and_add' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateAtomicRMW: callInstruction arguments first
				with: callInstruction arguments second
				operation: #add
		];
		addBuiltIn: #'atomic.fetch_and_subtract' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateAtomicRMW: callInstruction arguments first
				with: callInstruction arguments second
				operation: #sub
		];
	
		yourself
]

{ #category : #initialization }
SLVMLLVMBuiltInFunctionGenerator class >> bitwiseBuiltin [
	<builtInFunctions>
	self
		addBuiltIn: #'bitwise.ctpop' callOverloadedUnary: #'llvm.ctpop';
		addBuiltIn: #'bitwise.ctlz' callOverloadedUnary: #'llvm.ctlz';
		addBuiltIn: #'bitwise.cttz' callOverloadedUnary: #'llvm.cttz'
]

{ #category : #initialization }
SLVMLLVMBuiltInFunctionGenerator class >> fromName: intrinsicName [
	^ BuiltInFunctionDictionary at: intrinsicName ifAbsent: [ nil ]
]

{ #category : #initialization }
SLVMLLVMBuiltInFunctionGenerator class >> initialize [
	BuiltInFunctionDictionary := Dictionary new.
	
	self withAllSubclassesDo: [ :cls |
		cls class methodDict valuesDo: [ :method |
			(method hasPragmaNamed: #builtInFunctions) ifTrue: [ 
				cls perform: method selector
			]
		]
	]
]

{ #category : #initialization }
SLVMLLVMBuiltInFunctionGenerator class >> matrixBuiltIn [
	<builtInFunctions>
	self addBuiltIn: #'matrix.transpose' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
		functionCodeGenerator generateMatrix: builtInFunction functionType returnType byTransposing: callInstruction arguments first
	]
	
]

{ #category : #initialization }
SLVMLLVMBuiltInFunctionGenerator class >> vectorBuiltIn [
	<builtInFunctions>
	self
		addBuiltIn: #'vector.dot' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVectorDot: callInstruction arguments first with: callInstruction arguments second
		];
		addBuiltIn: #'vector.cross' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVector: builtInFunction functionType returnType cross: callInstruction arguments first with: callInstruction arguments second
		];
		yourself
]

{ #category : #'code generation' }
SLVMLLVMBuiltInFunctionGenerator >> generateWith: functionCodeGenerator builtInFunction: builtInFunction callInstruction: instruction [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMLLVMBuiltInFunctionGenerator >> name [
	^ name
]

{ #category : #accessing }
SLVMLLVMBuiltInFunctionGenerator >> name: anObject [
	name := anObject
]

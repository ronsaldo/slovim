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
SLVMLLVMBuiltInFunctionGenerator class >> addBuiltIn: builtInName callEquivalent: llvmBuiltInName [
	BuiltInFunctionDictionary at: builtInName put:
		(SLVMLLVMEquivalentBuiltInFunctionGenerator new
			name: builtInName;
			llvmBuiltIn: llvmBuiltInName;
			yourself)
]

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
		addBuiltIn: #'atomic.load' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateAtomicLoad: callInstruction arguments first
				returnType: callInstruction type
				ordering: (callInstruction arguments size > 1 ifTrue: [ callInstruction arguments last ] ifFalse: [ nil ])
		];
		addBuiltIn: #'atomic.store' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateAtomicStoreIn: callInstruction arguments first
				value: callInstruction arguments second
				ordering: (callInstruction arguments size > 2 ifTrue: [ callInstruction arguments last ] ifFalse: [ nil ])
		];
		addBuiltIn: #'atomic.compare_and_swap' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateAtomicCompare: callInstruction arguments first
				with: callInstruction arguments second
				andSwapWith: callInstruction arguments third
				ordering: (callInstruction arguments size > 3 ifTrue: [ callInstruction arguments last ] ifFalse: [ nil ])
				returnType: callInstruction type
		];
		addBuiltIn: #'atomic.test_and_set' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateAtomicRMW: callInstruction arguments first
				with: callInstruction arguments second
				operation: #xchg
				ordering: (callInstruction arguments size > 2 ifTrue: [ callInstruction arguments last ] ifFalse: [ nil ])
				returnType: callInstruction type
		];
		addBuiltIn: #'atomic.swap_value' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateAtomicRMW: callInstruction arguments first
				with: callInstruction arguments second
				operation: #xchg
				ordering: (callInstruction arguments size > 2 ifTrue: [ callInstruction arguments last ] ifFalse: [ nil ])
				returnType: callInstruction type
		];
		addBuiltIn: #'atomic.fetch_and_add' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateAtomicRMW: callInstruction arguments first
				with: callInstruction arguments second
				operation: #add
				ordering: (callInstruction arguments size > 2 ifTrue: [ callInstruction arguments last ] ifFalse: [ nil ])
				returnType: callInstruction type
		];
		addBuiltIn: #'atomic.fetch_and_subtract' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateAtomicRMW: callInstruction arguments first
				with: callInstruction arguments second
				operation: #sub
				ordering: (callInstruction arguments size > 2 ifTrue: [ callInstruction arguments last ] ifFalse: [ nil ])
				returnType: callInstruction type
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
SLVMLLVMBuiltInFunctionGenerator class >> gcBuiltin [
	<builtInFunctions>
	self
		addBuiltIn: #'gc.root' callEquivalent: #'llvm.gcroot';
		addBuiltIn: #'gc.read' callEquivalent: #'llvm.gcread';
		addBuiltIn: #'gc.write' callEquivalent: #'llvm.gcwrite'
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

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
SLVMLLVMBuiltInFunctionGenerator class >> addBuiltIn: builtInName callOverloadedBinarySameTypes: llvmBuiltInName [
	BuiltInFunctionDictionary at: builtInName put:
		(SLVMLLVMBinarySameTypesOverloadedBuiltInFunctionGenerator new
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
SLVMLLVMBuiltInFunctionGenerator class >> addBuiltIn: builtInName callScalarMathDoubleFunction: standardFunctionName [
	self addBuiltIn: builtInName inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateBuiltInCall: callInstruction byCallingScalarMathDoubleFunction: standardFunctionName
	]
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
	self
		addBuiltIn: #'matrix.all' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateMatrixAll: callInstruction arguments first
		];
		addBuiltIn: #'matrix.any' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateMatrixAny: callInstruction arguments first
		];
		addBuiltIn: #'matrix.transpose' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateMatrix: callInstruction type byTransposing: callInstruction arguments first
		];
		addBuiltIn: #'matrix.determinant' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateMatrixDeterminant: callInstruction arguments first
		];
		addBuiltIn: #'matrix.inverse' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateMatrixInverse: callInstruction arguments first
		];

		yourself
]

{ #category : #initialization }
SLVMLLVMBuiltInFunctionGenerator class >> shaderBarrierBuiltIn [
	<builtInFunctions>
	
	"Nop the shader barriers with this backend."
	self
		addBuiltIn: #'shader.barrier.execution' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
		];
		addBuiltIn: #'shader.barrier.memory.all' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
		];
		addBuiltIn: #'shader.barrier.memory.atomic_counter' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
		];
		addBuiltIn: #'shader.barrier.memory.image' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
		];
		addBuiltIn: #'shader.barrier.memory.buffer' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
		];
		addBuiltIn: #'shader.barrier.memory.shared' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
		];
		addBuiltIn: #'shader.barrier.memory.group' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
		]
]

{ #category : #initialization }
SLVMLLVMBuiltInFunctionGenerator class >> vectorBuiltIn [
	<builtInFunctions>
	self
		addBuiltIn: #'vector.dot' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVectorDot: callInstruction arguments first with: callInstruction arguments second
		];
		addBuiltIn: #'vector.all' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVectorAll: callInstruction arguments first
		];
		addBuiltIn: #'vector.any' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVectorAny: callInstruction arguments first
		];
		addBuiltIn: #'vector.length' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVectorLength: callInstruction arguments first
		];
		addBuiltIn: #'vector.normalize' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVectorNormalize: callInstruction arguments first
		];
		addBuiltIn: #'vector.cross' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVector: builtInFunction functionType returnType intrinsicCross: callInstruction arguments first with: callInstruction arguments second
		];
		yourself
]

{ #category : #initialization }
SLVMLLVMBuiltInFunctionGenerator class >> vectorPackingBuiltIn [
	<builtInFunctions>
	
	self
		addBuiltIn: #'pack.snorm2x16' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVector: callInstruction arguments first packMinValue: -1.0 maxValue: 1.0 channels: 2 channelSize: 16 channelScale: 32767.0 returnType: (functionCodeGenerator translateType: callInstruction type)
		];
		addBuiltIn: #'pack.unorm2x16' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVector: callInstruction arguments first packMinValue: 0.0 maxValue: 1.0 channels: 2 channelSize: 16 channelScale: 65535.0 returnType: (functionCodeGenerator translateType: callInstruction type)
		];
		addBuiltIn: #'pack.snorm4x8' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVector: callInstruction arguments first packMinValue: -1.0 maxValue: 1.0 channels: 4 channelSize: 8 channelScale: 127.0 returnType: (functionCodeGenerator translateType: callInstruction type)
		];
		addBuiltIn: #'pack.unorm4x8' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVector: callInstruction arguments first packMinValue: 0.0 maxValue: 1.0 channels: 4 channelSize: 8 channelScale: 255.0 returnType: (functionCodeGenerator translateType: callInstruction type)
		];

		addBuiltIn: #'unpack.snorm2x16' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVector: callInstruction arguments first signed: true unpackScale: 32767.0 channels: 2 channelSize: 16 returnType: (functionCodeGenerator translateType: callInstruction type)
		];
		addBuiltIn: #'unpack.unorm2x16' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVector: callInstruction arguments first signed: false unpackScale: 65535.0 channels: 2 channelSize: 16 returnType: (functionCodeGenerator translateType: callInstruction type)
		];
		addBuiltIn: #'unpack.snorm4x8' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVector: callInstruction arguments first signed: true unpackScale: 127.0 channels: 4 channelSize: 8 returnType: (functionCodeGenerator translateType: callInstruction type)
		];
		addBuiltIn: #'unpack.unorm4x8' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVector: callInstruction arguments first signed: false unpackScale: 255.0 channels: 4 channelSize: 8 returnType: (functionCodeGenerator translateType: callInstruction type)
		];
	
		addBuiltIn: #'pack.half2x16' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator bitCast: (functionCodeGenerator translateValue: callInstruction arguments first)
				target: (functionCodeGenerator translateType: callInstruction type)
				name: (functionCodeGenerator convertName: callInstruction name)
		];
		addBuiltIn: #'unpack.half2x16' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator bitCast: (functionCodeGenerator translateValue: callInstruction arguments first)
				target: (functionCodeGenerator translateType: callInstruction type)
				name: (functionCodeGenerator convertName: callInstruction name)
		]
]

{ #category : #initialization }
SLVMLLVMBuiltInFunctionGenerator class >> vectorScalarMathBuiltIn [
	<builtInFunctions>
	
	self
		addBuiltIn: 'math.pow' callOverloadedBinarySameTypes: 'llvm.pow';
		addBuiltIn: 'math.sqrt' callOverloadedUnary: 'llvm.sqrt';

		addBuiltIn: 'math.sin' callOverloadedUnary: 'llvm.sin';
		addBuiltIn: 'math.asin' callScalarMathDoubleFunction: 'asin';
		addBuiltIn: 'math.sinh' callScalarMathDoubleFunction: 'sinh';
		addBuiltIn: 'math.asin' callScalarMathDoubleFunction: 'asinh';

		addBuiltIn: 'math.cos' callOverloadedUnary: 'llvm.cos';
		addBuiltIn: 'math.acos' callScalarMathDoubleFunction: 'acos';
		addBuiltIn: 'math.cosh' callScalarMathDoubleFunction: 'cosh';
		addBuiltIn: 'math.acosh' callScalarMathDoubleFunction: 'acosh';

		addBuiltIn: 'math.tan' callScalarMathDoubleFunction: 'tan';
		addBuiltIn: 'math.atan' callScalarMathDoubleFunction: 'atan';
		addBuiltIn: 'math.atan2' callScalarMathDoubleFunction: 'atan2';
		addBuiltIn: 'math.tanh' callScalarMathDoubleFunction: 'tanh';
		addBuiltIn: 'math.atanh' callScalarMathDoubleFunction: 'atanh';

		addBuiltIn: 'math.exp' callOverloadedUnary: 'llvm.exp';
		addBuiltIn: 'math.exp2' callOverloadedUnary: 'llvm.exp2';
		addBuiltIn: 'math.log' callOverloadedUnary: 'llvm.log';
		addBuiltIn: 'math.log2' callOverloadedUnary: 'llvm.log2';

		addBuiltIn: 'math.floor' callOverloadedUnary: 'llvm.floor';
		addBuiltIn: 'math.ceil' callOverloadedUnary: 'llvm.ceil';
		addBuiltIn: 'math.trunc' callOverloadedUnary: 'llvm.trunc';
		addBuiltIn: 'math.round' callOverloadedUnary: 'llvm.round';
		addBuiltIn: 'math.fabs' callOverloadedUnary: 'llvm.fabs';
		
		addBuiltIn: #'math.fmin' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateMinMaxWithComparison: #ule of: callInstruction arguments first with: callInstruction arguments second.
		];
		addBuiltIn: #'math.umin' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateMinMaxWithComparison: #ule of: callInstruction arguments first with: callInstruction arguments second.
		];
		addBuiltIn: #'math.smin' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateMinMaxWithComparison: #sle of: callInstruction arguments first with: callInstruction arguments second.
		];
		addBuiltIn: #'math.fmax' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateMinMaxWithComparison: #uge of: callInstruction arguments first with: callInstruction arguments second.
		];
		addBuiltIn: #'math.umax' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateMinMaxWithComparison: #uge of: callInstruction arguments first with: callInstruction arguments second.
		];
		addBuiltIn: #'math.smax' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateMinMaxWithComparison: #sge of: callInstruction arguments first with: callInstruction arguments second.
		];
		addBuiltIn: #'math.fmix' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateMixFrom: callInstruction arguments first to: callInstruction arguments second at: callInstruction arguments third.
		];
		addBuiltIn: #'math.step' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateStepEdge: callInstruction arguments first value: callInstruction arguments second.
		];
		addBuiltIn: #'math.smoothstep' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateSmoothStepEdge: callInstruction arguments first edge: callInstruction arguments second value: callInstruction arguments third.
		];
		addBuiltIn: #'math.degrees' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVectorOrScalar: callInstruction arguments first constantMultiplication: "180.0 / Float pi" 57.29577951308232
		];
		addBuiltIn: #'math.radians' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVectorOrScalar: callInstruction arguments first constantMultiplication: "Float pi / 180.0"  0.017453292519943295
		];
		addBuiltIn: #'math.fsign' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVectorOrScalarSign: callInstruction arguments first
		];
		addBuiltIn: #'math.ssign' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVectorOrScalarSign: callInstruction arguments first
		];
		addBuiltIn: #'math.sabs' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVectorOrScalarAbsoluteValue: callInstruction arguments first
		];
		addBuiltIn: #'math.fract' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVectorOrScalarFloorFract: callInstruction arguments first
		];
		addBuiltIn: #'math.fmod' inlineWith: [ :functionCodeGenerator :builtInFunction :callInstruction |
			functionCodeGenerator generateVectorOrScalarFloorMod: callInstruction arguments first divisor: callInstruction arguments second
		].
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

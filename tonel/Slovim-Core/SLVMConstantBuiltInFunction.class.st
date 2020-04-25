Class {
	#name : #SLVMConstantBuiltInFunction,
	#superclass : #SLVMConstant,
	#instVars : [
		'functionType',
		'type',
		'name',
		'isPureFunction',
		'sexpression'
	],
	#classVars : [
		'ValidBuiltInFunctionNames'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'class initialization' }
SLVMConstantBuiltInFunction class >> initialize [
	"
	self initialize
	"
	ValidBuiltInFunctionNames := Set newFrom: ( #(
		"Atomic"
		'atomic.compare_and_swap'
		'atomic.fetch_and_add'
		'atomic.fetch_and_subtract'
		'atomic.swap_value'
		'atomic.load'
		'atomic.store'
		'atomic.test_and_set'
		
		"Context"
		'context.replace_function'
		'context.return_from_frame_value'
		
		"Bit manipulation"
		'bitwise.ctpop'
		'bitwise.ctlz'
		'bitwise.cttz'
		
		"Vector functions"
		'vector.cross'
		'vector.dot'
		'vector.length'
		'vector.normalize'
		'vector.reflect'
		'vector.refract'
		'vector.any'
		'vector.all'
		
		"Math functions"
		'math.smoothstep'
		'math.step'
		
		"Common functions"
		'math.umin'
		'math.smin'
		'math.fmin'
		
		'math.pow' 'math.atan2'
		
		'math.asin' 'math.sin' 'math.asinh' 'math.sinh'
		'math.acos' 'math.cos' 'math.acosh' 'math.cosh'
		'math.atan' 'math.tan' 'math.tanh' 'math.atanh'
		'math.exp' 'math.exp2' 'math.log' 'math.log2'
		'math.sqrt' 'math.inverseSqrt'
		'math.floor' 'math.ceil' 'math.trunc' 'math.round' 'math.roundEven' 'math.fract'
		'math.degrees' 'math.radians' 
		'math.fabs' 'math.sabs'
		'math.fsign' 'math.ssign'
			
		'math.umax'
		'math.smax'
		'math.fmax'
		
		'math.fmix'
		'math.fmod'
		
		"Matrix functions"
		'matrix.transpose'
		
		"Texture"
		'texture.query.size'
		'texture.query.lod.size'
		'texture.query.lod.count'
		'texture.image.read'
		'texture.image.write'
		'texture.image.fetch'
		
		"Fragment"
		'fragment.derivative.dx'
		'fragment.derivative.dy'
		'fragment.derivative.fwidth'
		'fragment.derivative.dx.fine'
		'fragment.derivative.dy.fine'
		'fragment.derivative.fwidth.fine'
		'fragment.derivative.dx.coarse'
		'fragment.derivative.dy.coarse'
		'fragment.derivative.fwidth.coarse'
		
		"Shader barriers"
		#'shader.barrier.execution'
		#'shader.barrier.memory.all'
		#'shader.barrier.memory.atomic_counter'
		#'shader.barrier.memory.image'
		#'shader.barrier.memory.buffer'
		#'shader.barrier.memory.shared'
		#'shader.barrier.memory.group'
		
		"Packing"
		#'pack.snorm2x16'
		#'pack.unorm2x16'
		#'pack.snorm4x8'
		#'pack.unorm4x8'
		#'pack.double2x32'
		#'pack.half2x16'
		#'unpack.snorm2x16'
		#'unpack.unorm2x16'
		#'unpack.snorm4x8'
		#'unpack.unorm4x8'
		#'unpack.double2x32'
		#'unpack.half2x16'

		"GC"
		'gc.root'
		'gc.read'
		'gc.write'
	) collect: [:each | each asSymbol]).
]

{ #category : #printing }
SLVMConstantBuiltInFunction class >> mnemonic [
	^ #builtInFunction
]

{ #category : #construction }
SLVMConstantBuiltInFunction class >> pointerSize: pointerSize name: aName functionType: aFunctionType [
	^ self new pointerSize: pointerSize name: aName functionType: aFunctionType
]

{ #category : #'as yet unclassified' }
SLVMConstantBuiltInFunction >> accept: aVisitor [
	^ aVisitor visitConstantBuiltInFunction: self
]

{ #category : #printing }
SLVMConstantBuiltInFunction >> asSExpression [
	^ sexpression ifNil: [sexpression := { self mnemonic . type asSExpression . name }]
]

{ #category : #accessing }
SLVMConstantBuiltInFunction >> functionType [
	^ functionType
]

{ #category : #'as yet unclassified' }
SLVMConstantBuiltInFunction >> initialize [
	super initialize.
	isPureFunction := true.
]

{ #category : #testing }
SLVMConstantBuiltInFunction >> isConstantBuiltInFunction [
	^ true
]

{ #category : #accessing }
SLVMConstantBuiltInFunction >> isPureFunction [
	^ isPureFunction
]

{ #category : #accessing }
SLVMConstantBuiltInFunction >> isPureFunction: anObject [
	isPureFunction := anObject
]

{ #category : #accessing }
SLVMConstantBuiltInFunction >> name [
	^ name
]

{ #category : #construction }
SLVMConstantBuiltInFunction >> pointerSize: pointerSize name: aName functionType: aFunctionType [
	self assert: (ValidBuiltInFunctionNames includes: aName).
	self assert: aFunctionType isSlovimType.
	name := aName.
	functionType := aFunctionType.
	type := SLVMPointerType size: pointerSize baseType: functionType storage: SLVMType genericStorage.
	
]

{ #category : #'as yet unclassified' }
SLVMConstantBuiltInFunction >> printOn: aStream [
	aStream nextPutAll: 'builtin '; print: name; space; print: functionType
]

{ #category : #accessing }
SLVMConstantBuiltInFunction >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantBuiltInFunction >> type: anObject [
	type := anObject
]

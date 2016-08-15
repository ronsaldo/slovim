Class {
	#name : #SLVMType,
	#superclass : #SLVMObject,
	#classVars : [
		'AtomicCounterStorage',
		'BoolType',
		'BuiltInTypes',
		'CharType',
		'CrossWorkgroupStorage',
		'DoubleType',
		'DynamicObjectType',
		'FloatType',
		'FunctionStorage',
		'GenericStorage',
		'ImageStorage',
		'InputStorage',
		'IntType',
		'LongType',
		'OutputStorage',
		'PrivateStorage',
		'PushConstantStorage',
		'SamplerType',
		'ShortType',
		'Textured1DArrayType',
		'Textured1DType',
		'Textured2DArrayType',
		'Textured2DType',
		'Textured3DArrayType',
		'Textured3DType',
		'TexturedCubeArrayType',
		'TexturedCubeType',
		'UCharType',
		'UIntType',
		'ULongType',
		'UShortType',
		'UniformConstantStorage',
		'UniformStorage',
		'VoidType',
		'WorkgroupStorage'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #'storage classes' }
SLVMType class >> atomicCounterStorage [
	^ AtomicCounterStorage
]

{ #category : #'built in types' }
SLVMType class >> boolType [
	^ BoolType
]

{ #category : #'class initialization' }
SLVMType class >> builtInTypes [
	BuiltInTypes ifNil: [ self initialize. ].
	^ BuiltInTypes
]

{ #category : #'built in types' }
SLVMType class >> charType [
	^ CharType
]

{ #category : #'storage classes' }
SLVMType class >> crossWorkgroupStorage [
	^ CrossWorkgroupStorage
]

{ #category : #'built in types' }
SLVMType class >> doubleType [
	^ DoubleType
]

{ #category : #'built in types' }
SLVMType class >> dynamicObjectType [
	^ DynamicObjectType
]

{ #category : #'built in types' }
SLVMType class >> floatType [
	^ FloatType
]

{ #category : #'storage classes' }
SLVMType class >> functionStorage [
	^ FunctionStorage
]

{ #category : #'storage classes' }
SLVMType class >> genericStorage [
	^ GenericStorage
]

{ #category : #'storage classes' }
SLVMType class >> imageStorage [
	^ ImageStorage
]

{ #category : #'class initialization' }
SLVMType class >> initialize [
	"
	self initialize
	"
	super initialize.
	
	UniformConstantStorage := #uniformConstant.
	UniformStorage := 	#uniform.
	InputStorage := #input.
	OutputStorage := #output.
	GenericStorage := #generic.
	WorkgroupStorage := #workgroup.
	CrossWorkgroupStorage := #crossWorkgroup.
	PrivateStorage := #private.
	FunctionStorage := #function.
	GenericStorage := #generic.
	PushConstantStorage := #pushConstant.
	AtomicCounterStorage := #atomicCounter.
	ImageStorage := #image.
	
	BuiltInTypes := IdentityDictionary new.
	(
		self primitiveTypes,
		self vectorTypes,
		self matrixTypes,
		self textureAndSamplerTypes
	) do: [ :type | BuiltInTypes at: type name put: type ]
	
]

{ #category : #'storage classes' }
SLVMType class >> inputStorage [
	^ InputStorage
]

{ #category : #'built in types' }
SLVMType class >> intType [
	^ IntType
]

{ #category : #'built in types' }
SLVMType class >> longType [
	^ LongType
]

{ #category : #'class initialization' }
SLVMType class >> matrixTypes [
	^ {
		SLVMMatrixType baseType: FloatType rows: 2 columns: 2.
		SLVMMatrixType baseType: FloatType rows: 3 columns: 3.
		SLVMMatrixType baseType: FloatType rows: 4 columns: 4.
		
		SLVMMatrixType baseType: DoubleType rows: 2 columns: 2.
		SLVMMatrixType baseType: DoubleType rows: 3 columns: 3.
		SLVMMatrixType baseType: DoubleType rows: 4 columns: 4.
	}
]

{ #category : #'storage classes' }
SLVMType class >> outputStorage [
	^ OutputStorage
]

{ #category : #'class initialization' }
SLVMType class >> primitiveTypes [
	VoidType := SLVMVoidType new name: #void.
	DynamicObjectType := SLVMDynamicObjectType new name: #dynobject.
	BoolType := SLVMBoolType name: #bool size: 1 alignment: 1.
	
	CharType := SLVMIntegerType name: #char size: 1 alignment: 1.
	ShortType := SLVMIntegerType name: #short size: 2 alignment: 2.
	IntType := SLVMIntegerType name: #int size: 4 alignment: 4.
	LongType := SLVMIntegerType name: #long size: 8 alignment: 8.

	UCharType := SLVMIntegerType name: #uchar size: 1 alignment: 1 signed: false.
	UShortType := SLVMIntegerType name: #ushort size: 2 alignment: 2 signed: false.
	UIntType := SLVMIntegerType name: #uint size: 4 alignment: 4 signed: false.
	ULongType := SLVMIntegerType name: #ulong size: 8 alignment: 8 signed: false.
	
	FloatType := SLVMFloatType name: #float size: 4 alignment: 4.	
	DoubleType := SLVMFloatType name: #double size: 8 alignment: 8.
	
	^ {
		VoidType.
		DynamicObjectType.
		BoolType.
		
		CharType.
		ShortType.
		IntType.
		LongType.

		UCharType.
		UShortType.
		UIntType.
		ULongType.
		
		FloatType.
		DoubleType.
	}
]

{ #category : #'storage classes' }
SLVMType class >> privateStorage [
	^ PrivateStorage
]

{ #category : #'storage classes' }
SLVMType class >> pushConstantStorage [
	^ PushConstantStorage
]

{ #category : #'built in types' }
SLVMType class >> samplerType [
	^ SamplerType
]

{ #category : #'built in types' }
SLVMType class >> shortType [
	^ ShortType
]

{ #category : #'built in types' }
SLVMType class >> textureAndSamplerTypes [
	SamplerType := SLVMSamplerType new name: #sampler.

	Textured1DType := SLVMTextureType new name: #texture1D; sampledType: FloatType; dimensions: 1; array: false; depth: false; multisample: false; sampled: true.	
	Textured1DArrayType := SLVMTextureType new name: #texture1DArray; sampledType: FloatType; dimensions: 1; array: true; depth: false; multisample: false; sampled: true.
	Textured2DType := SLVMTextureType new name: #texture2D; dimensions: 2; sampledType: FloatType; array: false; depth: false; multisample: false; sampled: true.
	Textured2DArrayType := SLVMTextureType new name: #texture2DArray; sampledType: FloatType; dimensions: 2; array: true; depth: false; multisample: false; sampled: true.
	Textured3DType := SLVMTextureType new name: #texture3D; dimensions: 3; sampledType: FloatType; array: false; depth: false; multisample: false; sampled: true.
	Textured3DArrayType := SLVMTextureType new name: #texture3DArray; sampledType: FloatType; dimensions: 3; array: true; depth: false; multisample: false; sampled: true.
	TexturedCubeType := SLVMTextureType new name: #textureCube; dimensions: 4; sampledType: FloatType; array: false; depth: false; multisample: false; sampled: true.
	TexturedCubeArrayType := SLVMTextureType new name: #textureCubeArray; sampledType: FloatType; dimensions: 4; array: true; depth: false; multisample: false; sampled: true.
	
	^ {
		SamplerType .
		Textured1DType .
		Textured1DArrayType .
		Textured2DType .
		Textured2DArrayType .
		Textured3DType .
		Textured3DArrayType .
		TexturedCubeType .
		TexturedCubeArrayType .
	}
]

{ #category : #'built in types' }
SLVMType class >> ucharType [
	^ UCharType
]

{ #category : #'built in types' }
SLVMType class >> uintType [
	^ UIntType
]

{ #category : #'built in types' }
SLVMType class >> ulongType [
	^ ULongType
]

{ #category : #'storage classes' }
SLVMType class >> uniformConstantStorage [
	^ UniformConstantStorage
]

{ #category : #'storage classes' }
SLVMType class >> uniformStorage [
	^ UniformStorage
]

{ #category : #'built in types' }
SLVMType class >> ushortType [
	^ UShortType
]

{ #category : #'class initialization' }
SLVMType class >> vectorTypes [
	^ {
		SLVMVectorType baseType: FloatType elements: 2.
		SLVMVectorType baseType: FloatType elements: 3.
		SLVMVectorType baseType: FloatType elements: 4.
		
		SLVMVectorType baseType: DoubleType elements: 2.
		SLVMVectorType baseType: DoubleType elements: 3.
		SLVMVectorType baseType: DoubleType elements: 4.
		
		SLVMVectorType baseType: IntType elements: 2.
		SLVMVectorType baseType: IntType elements: 3.
		SLVMVectorType baseType: IntType elements: 4.
		
		SLVMVectorType baseType: UIntType elements: 2.
		SLVMVectorType baseType: UIntType elements: 3.
		SLVMVectorType baseType: UIntType elements: 4.

		SLVMVectorType baseType: ShortType elements: 2.
		SLVMVectorType baseType: ShortType elements: 3.
		SLVMVectorType baseType: ShortType elements: 4.

		SLVMVectorType baseType: UShortType elements: 2.
		SLVMVectorType baseType: UShortType elements: 3.
		SLVMVectorType baseType: UShortType elements: 4.

		SLVMVectorType baseType: CharType elements: 2.
		SLVMVectorType baseType: CharType elements: 3.
		SLVMVectorType baseType: CharType elements: 4.

		SLVMVectorType baseType: UCharType elements: 2.
		SLVMVectorType baseType: UCharType elements: 3.
		SLVMVectorType baseType: UCharType elements: 4.
	}
]

{ #category : #'built in types' }
SLVMType class >> voidType [
	^ VoidType
]

{ #category : #'storage classes' }
SLVMType class >> workgroupStorage [
	^ WorkgroupStorage
]

{ #category : #visitor }
SLVMType >> accept: aVisitor [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMType >> alignment [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SLVMType >> alignmentForTarget: aTarget [
	^ self alignment
]

{ #category : #testing }
SLVMType >> asSlovimType [
	^ self
]

{ #category : #testing }
SLVMType >> isArrayType [
	^ false
]

{ #category : #testing }
SLVMType >> isBooleanType [
	^ false
]

{ #category : #testing }
SLVMType >> isDynamicObjectType [
	^ false
]

{ #category : #testing }
SLVMType >> isFloatType [
	^ false
]

{ #category : #testing }
SLVMType >> isFunctionType [
	^ false
]

{ #category : #testing }
SLVMType >> isInstruction [
	^ false
]

{ #category : #testing }
SLVMType >> isIntegerType [
	^ false
]

{ #category : #testing }
SLVMType >> isMatrixType [
	^ false
]

{ #category : #testing }
SLVMType >> isOpaqueType [
	^ false
]

{ #category : #testing }
SLVMType >> isPrimitiveType [
	^ false
]

{ #category : #testing }
SLVMType >> isReferenceType [
	^ false
]

{ #category : #testing }
SLVMType >> isSampledTextureType [
	^ false
]

{ #category : #testing }
SLVMType >> isSamplerType [
	^ false
]

{ #category : #testing }
SLVMType >> isScalarType [
	^ false
]

{ #category : #testing }
SLVMType >> isSlovimType [
	^ true
]

{ #category : #testing }
SLVMType >> isStructureType [
	^ false
]

{ #category : #testing }
SLVMType >> isTextureType [
	^ false
]

{ #category : #testing }
SLVMType >> isType [
	^ true
]

{ #category : #testing }
SLVMType >> isVectorType [
	^ false
]

{ #category : #testing }
SLVMType >> isVoidType [
	^ false
]

{ #category : #accessing }
SLVMType >> size [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SLVMType >> sizeAndAlignmentForTarget: aTarget [
	^ { self sizeForTarget: aTarget . self alignmentForTarget: aTarget }
]

{ #category : #'as yet unclassified' }
SLVMType >> sizeForTarget: aTarget [
	^ self size
]

{ #category : #accessing }
SLVMType >> useScope [
	^ nil
]

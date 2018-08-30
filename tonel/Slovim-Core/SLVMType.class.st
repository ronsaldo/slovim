Class {
	#name : #SLVMType,
	#superclass : #SLVMObject,
	#instVars : [
		'hash'
	],
	#classVars : [
		'AtomicCounterStorage',
		'BoolType',
		'BuiltInTypes',
		'CharType',
		'CrossWorkgroupStorage',
		'DepthTexture2DArrayType',
		'DepthTexture2DType',
		'DepthTextureCubeArrayType',
		'DepthTextureCubeType',
		'DoubleAlign4Type',
		'DoubleAlign8Type',
		'DynobjectStorage',
		'Float2Type',
		'Float3Type',
		'Float4Type',
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
		'Texture1DArrayType',
		'Texture1DType',
		'Texture2DArrayType',
		'Texture2DType',
		'Texture3DArrayType',
		'Texture3DType',
		'TextureCubeArrayType',
		'TextureCubeType',
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
SLVMType class >> doubleAlign4Type [
	^ DoubleAlign4Type
]

{ #category : #'built in types' }
SLVMType class >> doubleAlign8Type [
	^ DoubleAlign8Type
]

{ #category : #'storage classes' }
SLVMType class >> dynobjectStorage [
	^ DynobjectStorage
]

{ #category : #'built in types' }
SLVMType class >> float3Type [
	^ Float3Type
]

{ #category : #'built in types' }
SLVMType class >> float4Type [
	^ Float4Type
]

{ #category : #'built in types' }
SLVMType class >> floatType [
	^ FloatType
]

{ #category : #'built in types' }
SLVMType class >> floatVectorTypes [
	^ {FloatType . Float2Type . Float3Type . Float4Type }
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
	DynobjectStorage := #gc.
	
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
		
		SLVMMatrixType baseType: DoubleAlign4Type rows: 2 columns: 2.
		SLVMMatrixType baseType: DoubleAlign4Type rows: 3 columns: 3.
		SLVMMatrixType baseType: DoubleAlign4Type rows: 4 columns: 4.

		SLVMMatrixType baseType: DoubleAlign8Type rows: 2 columns: 2.
		SLVMMatrixType baseType: DoubleAlign8Type rows: 3 columns: 3.
		SLVMMatrixType baseType: DoubleAlign8Type rows: 4 columns: 4.
	}
]

{ #category : #'storage classes' }
SLVMType class >> outputStorage [
	^ OutputStorage
]

{ #category : #'class initialization' }
SLVMType class >> primitiveTypes [
	VoidType := SLVMVoidType new name: #void.
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
	DoubleAlign8Type := SLVMFloatType name: #doubleAlign8 size: 8 alignment: 8.
	DoubleAlign4Type := SLVMFloatType name: #doubleAlign4 size: 8 alignment: 4.
	
	^ {
		VoidType.
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
		DoubleAlign4Type.
		DoubleAlign8Type.
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

{ #category : #'class initialization' }
SLVMType class >> textureAndSamplerTypes [
	SamplerType := SLVMSamplerType new name: #sampler.

	Texture1DType := SLVMTextureType new name: #texture1D; sampledType: FloatType; dimensions: 1; array: false; depth: false; multisample: false; sampled: true.	
	Texture1DArrayType := SLVMTextureType new name: #texture1DArray; sampledType: FloatType; dimensions: 1; array: true; depth: false; multisample: false; sampled: true.
	Texture2DType := SLVMTextureType new name: #texture2D; dimensions: 2; sampledType: FloatType; array: false; depth: false; multisample: false; sampled: true.
	Texture2DArrayType := SLVMTextureType new name: #texture2DArray; sampledType: FloatType; dimensions: 2; array: true; depth: false; multisample: false; sampled: true.
	Texture3DType := SLVMTextureType new name: #texture3D; dimensions: 3; sampledType: FloatType; array: false; depth: false; multisample: false; sampled: true.
	Texture3DArrayType := SLVMTextureType new name: #texture3DArray; sampledType: FloatType; dimensions: 3; array: true; depth: false; multisample: false; sampled: true.
	TextureCubeType := SLVMTextureType new name: #textureCube; dimensions: 4; sampledType: FloatType; array: false; depth: false; multisample: false; sampled: true.
	TextureCubeArrayType := SLVMTextureType new name: #textureCubeArray; sampledType: FloatType; dimensions: 4; array: true; depth: false; multisample: false; sampled: true.

	DepthTexture2DType := SLVMTextureType new name: #depthTexture2D; dimensions: 2; sampledType: FloatType; array: false; depth: true; multisample: false; sampled: true.
	DepthTexture2DArrayType := SLVMTextureType new name: #depthTexture2DArray; sampledType: FloatType; dimensions: 2; array: true; depth: true; multisample: false; sampled: true.
	DepthTextureCubeType := SLVMTextureType new name: #depthTextureCube; dimensions: 4; sampledType: FloatType; array: false; depth: true; multisample: false; sampled: true.
	DepthTextureCubeArrayType := SLVMTextureType new name: #depthTextureCubeArray; sampledType: FloatType; dimensions: 4; array: true; depth: true; multisample: false; sampled: true.
	
	^ {
		SamplerType .
		Texture1DType .
		Texture1DArrayType .
		Texture2DType .
		Texture2DArrayType .
		Texture3DType .
		Texture3DArrayType .
		TextureCubeType .
		TextureCubeArrayType .
		
		DepthTexture2DType.
		DepthTexture2DArrayType.
		DepthTextureCubeType.
		DepthTextureCubeArrayType.
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
	Float2Type := SLVMVectorType baseType: FloatType elements: 2.
	Float3Type := SLVMVectorType baseType: FloatType elements: 3.
	Float4Type := SLVMVectorType baseType: FloatType elements: 4.
		
	^ {
		Float2Type.
		Float3Type.
		Float4Type.
		
		SLVMVectorType baseType: DoubleAlign4Type elements: 2.
		SLVMVectorType baseType: DoubleAlign4Type elements: 3.
		SLVMVectorType baseType: DoubleAlign4Type elements: 4.

		SLVMVectorType baseType: DoubleAlign8Type elements: 2.
		SLVMVectorType baseType: DoubleAlign8Type elements: 3.
		SLVMVectorType baseType: DoubleAlign8Type elements: 4.		
		
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

{ #category : #accessing }
SLVMType >> asGenericMessageType [
	^ self
]

{ #category : #testing }
SLVMType >> asSLVMType [
	^ self
]

{ #category : #testing }
SLVMType >> asSlovimType: compilationTarget [
	^ self
]

{ #category : #'constant encoding' }
SLVMType >> encodeConstant: value bigEndian: bigEndian intoByteStream: stream [
	self subclassResponsibility
]

{ #category : #comparing }
SLVMType >> hash [
	^ hash ifNil: [hash := self internalHash ]
]

{ #category : #comparing }
SLVMType >> internalHash [
	self subclassResponsibility
]

{ #category : #testing }
SLVMType >> isAggregateType [
	^ false
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
SLVMType >> isClosureType [
	^ false
]

{ #category : #testing }
SLVMType >> isDynamicObjectPointerType [
	^ false
]

{ #category : #testing }
SLVMType >> isDynamicObjectType [
	^ false
]

{ #category : #testing }
SLVMType >> isFloatMatrixType [
	^ false
]

{ #category : #testing }
SLVMType >> isFloatType [
	^ false
]

{ #category : #testing }
SLVMType >> isFloatVectorType [
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
SLVMType >> isIntegerMatrixType [
	^ false
]

{ #category : #testing }
SLVMType >> isIntegerType [
	^ false
]

{ #category : #testing }
SLVMType >> isIntegerVectorType [
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
SLVMType >> isPointerType [
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
SLVMType >> isScalarIntegerType [
	^ self isScalarType and: [ self isFloatType not ]
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

{ #category : #'as yet unclassified' }
SLVMType >> loadValueFromPointerWith: irBuilder [
	^ irBuilder send: self selectorForLoadingFromPointer
]

{ #category : #'as yet unclassified' }
SLVMType >> pointerStoreValueWith: irBuilder [
	irBuilder
		send: self selectorForPointerStoring
]

{ #category : #'pointer accessing' }
SLVMType >> readFromPointer: pointer [
	^ #unreadable
]

{ #category : #accessing }
SLVMType >> registerClass [
	^ nil
]

{ #category : #'as yet unclassified' }
SLVMType >> selectorForLoadingFromPointer [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SLVMType >> selectorForStoring [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SLVMType >> selectorForStoringIntoPointer [
	self subclassResponsibility
]

{ #category : #'constant encoding' }
SLVMType >> shortName [
	^ self asString
]

{ #category : #accessing }
SLVMType >> size [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMType >> spillingClass [
	^ { self size . self alignment . false }
]

{ #category : #'as yet unclassified' }
SLVMType >> storeAndPopValueIntoPointerWith: irBuilder [
	irBuilder
		send: self selectorForStoringIntoPointer;
		popTop
]

{ #category : #'as yet unclassified' }
SLVMType >> storeAndPopValueWith: irBuilder [
	irBuilder
		send: self selectorForStoring;
		popTop
]

{ #category : #'as yet unclassified' }
SLVMType >> storeValueIntoPointerWith: irBuilder [
	irBuilder
		send: self selectorForStoringIntoPointer
]

{ #category : #'as yet unclassified' }
SLVMType >> storeValueWith: irBuilder [
	irBuilder
		send: self selectorForStoring
]

{ #category : #accessing }
SLVMType >> useScope [
	^ nil
]

{ #category : #'pointer accessing' }
SLVMType >> write: value intoPointer: pointer [

]

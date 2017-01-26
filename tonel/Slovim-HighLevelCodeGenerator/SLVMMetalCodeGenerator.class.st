Class {
	#name : #SLVMMetalCodeGenerator,
	#superclass : #SLVMHighLevelLanguageCodeGenerator,
	#classVars : [
		'Keywords',
		'RenamedSymbols',
		'SamplerTypeDictionary',
		'SamplerTypeMapping',
		'SpecialSemanticVariableMap',
		'StorageToAddressSpaceMap',
		'TargetBuiltInMappings',
		'TypeDictionary',
		'TypeMapping'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #name }
SLVMMetalCodeGenerator class >> codeGeneratorName [
	^ #metal
]

{ #category : #name }
SLVMMetalCodeGenerator class >> initialize [
	super initialize.
	self initializeKeywordSet.
	self initializeTypeMappings.
	self initializeTargetBuiltInMappings.
	self initializeRenamedSymbols.
	self initializeStorageMap.
]

{ #category : #name }
SLVMMetalCodeGenerator class >> initializeKeywordSet [
	Keywords := Set newFrom: #(
		alignas
		alignof
		and
		and_eq
		asm
		auto
		bitand
		bitor
		bool
		break
		case
		catch
		char
		char16_t
		char32_t
		class
		compl
		const
		constexpr
		const_cast
		continue
		decltype
		default
		delete
		do
		double
		dynamic_cast
		else
	
		enum
		explicit
		export
		extern
		false
		float
		for
		friend
		goto
		if
		inline
		int
		long
		mutable
		namespace
		new
		noexcept
		not
		not_eq
		nullptr
		operator
		or
		or_eq
		private
		protected
		public
		register
		reinterpret_cast
		
		return
		short
		signed
		sizeof
		static
		static_assert
		static_cast
		struct
		switch
		template
		this
		thread_local
		throw
		true
		try
		typedef
		typeid
		typename
		union
		unsigned
		using
		virtual
		void
		volatile
		wchar_t
		while
		xor
		xor_eq
	)
]

{ #category : #name }
SLVMMetalCodeGenerator class >> initializeRenamedSymbols [
	RenamedSymbols := Dictionary newFromPairs: #(
		main shaderMain
	).
]

{ #category : #name }
SLVMMetalCodeGenerator class >> initializeStorageMap [
	StorageToAddressSpaceMap := Dictionary newFromPairs: #(
		uniform device
		uniformConstant constant
		pushConstant constant
		input thread
		output thread
		function thread
		workgroup threadgroup
		crossWorkgroup threadgroup
	)
]

{ #category : #name }
SLVMMetalCodeGenerator class >> initializeTargetBuiltInMappings [
	TargetBuiltInMappings := Dictionary newFromPairs: #(
		'binop.dynObjectIdentityEquals' ('slvm::dynrun::identityEquals' call)
		'binop.dynObjectIdentityNotEquals' ('slvm::dynrun::identityNotEquals' call)

		'message.identity-equals'				('slvm::dynrun::identityEquals' call)
		'message.identity-not-equals'			('slvm::dynrun::identityNotEquals' call)
		
		'message.add'				(+ binary)
		'message.sub'				(- binary)
		'message.mul'				(* binary)
		'message.div'				(/ binary)
		'message.integer-division'				('slvm::dynrun::integerDivision' call)
		'message.remainder'		(% binary)

		'message.less'				(< binary)
		'message.less-equal'		(<= binary)
		'message.greater'			(> binary)
		'message.greater-equal'	(>= binary)
		'message.equals'			(= binary)
		'message.not-equals'		(~= binary)

		'message.negated'			(- unary)
		'message.not'				(! unary)
			
		'message.bit-and'			(& binary)
		'message.bit-or'			(| binary)
		'message.bit-xor'			(^ binary)

		'message.at'					(at member)
		'message.at-put'			(atPut member)
		'message.size'				(size member)
		'message.class'				(getClass member)
		
		'message.value'				(value member)
		'message.value.1'			(value member)
		'message.set-x'				(x member)
		'message.set-y'				(y member)
		'message.basic-new'		(basicNew member)
		'message.basic-new-size'	(basicNew member)

		'sample.implicit_lod' (sample patternCall
			(('${sampleFunction}' sample) ))
		
		#'math.acos'	(#'metal::acos' call)
		#'math.acosh'	(#'metal::acosh' call)
		#'math.asin'	(#'metal::asin' call)
		#'math.asinh'	(#'metal::asinh' call)
		#'math.atan2'	(#'metal::atan2' call)
		#'math.atan'	(#'metal::atan' call)
		#'math.atanh'	(#'metal::atanh' function)
		#'math.ceil'	(#'metal::ceil' function)
		#'math.cos'     (#'metal::cos' function)
		#'math.cosh'	(#'metal::cosh' call)
		#'math.degrees'	(#'metal::degrees' call)
		#'math.exp2'	(#'metal::exp2' call)
		#'math.exp'     (#'metal::exp' call)
		#'math.fabs'	(#'metal::abs' call)
		#'math.floor'	(#'metal::floor' call)
		#'math.fmax'	(#'metal::max' call)
		#'math.fmin'	(#'metal::min' call)
		#'math.fmix'	(#'metal::mix' call)
		#'math.fract'	(#'metal::fract' call)
		#'math.fsign'	(#'metal::fsign' call)
		#'math.inverseSqrt'	(#'metal::inverseSqrt' call)
		#'math.log2'	(#'metal::log2' call)
		#'math.log'	    (#'metal::log' call)
		#'math.pow'     (#'metal::pow' call)
		#'math.radians'	(#'metal::radians' call)
		#'math.roundEven'	(#'metal::roundEven' call)
		#'math.round'	(#'metal::round' call)
		#'math.sinh'	(#'metal::sinh' call)
		#'math.sin'     (#'metal::sin' call)
		#'math.smax'	(#'metal::max' call)
		#'math.smin'	(#'metal::min' call)
		#'math.smoothstep'	(#'metal::smoothstep' call)
		#'math.sqrt'	(#'metal::sqrt' call)
		#'math.step'	(#'metal::step' call)
		#'math.tan'	(#'metal::tan' call)
		#'math.trunc'	(#'metal::trunc' call)
		#'math.umax'	(#'metal::max' call)
		#'math.umin'	(#'metal::min' call)
		#'matrix.transpose'	(#'metal::transpose' call)
		#'vector.cross'     (#'metal::cross' call)
		#'vector.dot'	    (#'metal::dot' call)
		#'vector.length'	(#'metal::length' call)
		#'vector.normalize'	(#'metal::normalize' call)
		#'vector.reflect'	(#'metal::reflect' call)
		#'vector.refract'	(#'metal::refract' call)
	)
]

{ #category : #name }
SLVMMetalCodeGenerator class >> initializeTypeMappings [
	| builtInTypes |
	TypeMapping := #(
		void void
		bool bool
		char char
		short short
		int int
		uint uint
		long long
		ulong ulong
		float float
		double double
		float2 'metal::float2'
		float3 'metal::float3'
		float4 'metal::float4'
		float2x2 'metal::float2x2'
		float3x3 'metal::float3x3'
		float4x4 'metal::float4x4'
		
		int2 'metal::int2'
		int3 'metal::int3'
		int4 'metal::int4'
		uint2 'metal::uint2'
		uint3 'metal::uint3'
		uint4 'metal::uint4'

		short2 'metal::short2'
		short3 'metal::short3'
		short4 'metal::short4'
		ushort2 'metal::ushort2'
		ushort3 'metal::ushort3'
		ushort4 'metal::ushort4'
		
		texture2D 'texture2d<float>'
		textureCube 'textureCube<float>'
		sampler sampler
	).
	
	SamplerTypeMapping := #(
		texture2D sampler2D
		textureCube samplerCube
	).
	
	TypeDictionary := Dictionary new.
	SamplerTypeDictionary := Dictionary new.
	builtInTypes := SLVMType builtInTypes.
	TypeMapping pairsDo: [ :myName :mappedName |
		TypeDictionary at: (builtInTypes at: myName) put: mappedName
	].

	TypeDictionary
		at: (SLVMDynamicObjectType new size: 4) put: 'slvm::dynrun::object';
		at: (SLVMDynamicObjectType new size: 8) put: 'slvm::dynrun::object'.
	
	SamplerTypeMapping pairsDo: [ :myName :mappedName |
		TypeDictionary at: (SLVMSampledTextureType new texture: (builtInTypes at: myName)) put: mappedName
		
	].

	SpecialSemanticVariableMap := Dictionary newFromPairs: #(
		-1 position
	)
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> dereferenceVariable: variable [
	| result |
	result := variable translateValueWith: self.
	(variable isGlobalVariable or: [ variable isReferenceAsPointer ]) ifTrue: [ ^ '(*' , result , ')' ].
	^ result
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> emitPrelude [
	self
		emitLine: '#include <metal_stdlib>';
		emitNewline
]

{ #category : #testing }
SLVMMetalCodeGenerator >> isBlackListedSymbol: aSymbol [
	^ Keywords includes: aSymbol
]

{ #category : #testing }
SLVMMetalCodeGenerator >> isRenamedSymbol: aSymbol [
	^ RenamedSymbols includesKey: aSymbol
]

{ #category : #testing }
SLVMMetalCodeGenerator >> mapBuiltInFunction: aFunctionName [
	TargetBuiltInMappings at: aFunctionName ifPresent: [ :mapping | ^ mapping ].
	^ super mapBuiltInFunction: aFunctionName
]

{ #category : #testing }
SLVMMetalCodeGenerator >> passGlobalsAsParameters [
	^ true
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> pointerAddressSpaceFor: storage [
	^ StorageToAddressSpaceMap at: storage
]

{ #category : #testing }
SLVMMetalCodeGenerator >> renameSymbol: aSymbol [
	^ RenamedSymbols at: aSymbol
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> translateBasicTypeName: aType [
	^ TypeDictionary at: aType
]

{ #category : #visitor }
SLVMMetalCodeGenerator >> translateHLCombineSamplerWithTexture: combine [
	^ ByteString streamContents: [ :out |
		out
			nextPutAll: (combine texture translateValueWith: self);
			nextPutAll: '.${sampleFunction}(';
			nextPutAll: (combine sampler translateValueWith: self)
	]	
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> translateHLElementReferenceValue: statement [
	statement reference isGlobalVariable ifFalse: [
		^ super translateHLElementReferenceValue: statement
	].

	statement isStructureMember  ifTrue: [
		^ '{1}->{2}' format: { statement reference translateValueWith: self . statement member name }
	] ifFalse: [ 
		^ '(*{1})[{2}]' format: { statement reference translateValueWith: self . statement member translateValueWith: self }
	].


]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> translateHLVariableDeclReference: variable [
	variable type isReferenceType ifFalse: [ ^ '&' , variable name ].
	^ variable name
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> translateHLVariableDeclValue: variable [
	^ variable name
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> translatePointerType: type [
	| baseType name |
	baseType := self translateType: type baseType.
	name := (self pointerAddressSpaceFor: type storage), ' ' , baseType name , '*'.
	^ SLVMHLReferenceTypeNode new baseType: baseType; name: name asSymbol; yourself
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> unboundedArrayNotation [
	^ '[1]'
]

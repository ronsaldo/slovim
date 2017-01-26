Class {
	#name : #SLVMMetalCodeGenerator,
	#superclass : #SLVMHighLevelLanguageCodeGenerator,
	#classVars : [
		'Keywords',
		'RenamedSymbols',
		'SamplerTypeDictionary',
		'SamplerTypeMapping',
		'SpecialSemanticVariableMap',
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
		
		#'math.acos'	(#'simd::acos' call)
		#'math.acosh'	(#'simd::acosh' call)
		#'math.asin'	(#'simd::asin' call)
		#'math.asinh'	(#'simd::asinh' call)
		#'math.atan2'	(#'simd::atan2' call)
		#'math.atan'	(#'simd::atan' call)
		#'math.atanh'	(#'simd::atanh' function)
		#'math.ceil'	(#'simd::ceil' function)
		#'math.cos'     (#'simd::cos' function)
		#'math.cosh'	(#'simd::cosh' call)
		#'math.degrees'	(#'simd::degrees' call)
		#'math.exp2'	(#'simd::exp2' call)
		#'math.exp'     (#'simd::exp' call)
		#'math.fabs'	(#'simd::abs' call)
		#'math.floor'	(#'simd::floor' call)
		#'math.fmax'	(#'simd::max' call)
		#'math.fmin'	(#'simd::min' call)
		#'math.fmix'	(#'simd::mix' call)
		#'math.fract'	(#'simd::fract' call)
		#'math.fsign'	(#'simd::fsign' call)
		#'math.inverseSqrt'	(#'simd::inverseSqrt' call)
		#'math.log2'	(#'simd::log2' call)
		#'math.log'	    (#'simd::log' call)
		#'math.pow'     (#'simd::pow' call)
		#'math.radians'	(#'simd::radians' call)
		#'math.roundEven'	(#'simd::roundEven' call)
		#'math.round'	(#'simd::round' call)
		#'math.sinh'	(#'simd::sinh' call)
		#'math.sin'     (#'simd::sin' call)
		#'math.smax'	(#'simd::max' call)
		#'math.smin'	(#'simd::min' call)
		#'math.smoothstep'	(#'simd::smoothstep' call)
		#'math.sqrt'	(#'simd::sqrt' call)
		#'math.step'	(#'simd::step' call)
		#'math.tan'	(#'simd::tan' call)
		#'math.trunc'	(#'simd::trunc' call)
		#'math.umax'	(#'simd::max' call)
		#'math.umin'	(#'simd::min' call)
		#'matrix.transpose'	(#'simd::transpose' call)
		#'vector.cross'     (#'simd::cross' call)
		#'vector.dot'	    (#'simd::dot' call)
		#'vector.length'	(#'simd::length' call)
		#'vector.normalize'	(#'simd::normalize' call)
		#'vector.reflect'	(#'simd::reflect' call)
		#'vector.refract'	(#'simd::refract' call)
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
		float2 'simd::float2'
		float3 'simd::float3'
		float4 'simd::float4'
		float2x2 'simd::float2x2'
		float3x3 'simd::float3x3'
		float4x4 'simd::float4x4'
		
		int2 'simd::int2'
		int3 'simd::int3'
		int4 'simd::int4'
		uint2 'simd::uint2'
		uint3 'simd::uint3'
		uint4 'simd::uint4'

		short2 'simd::short2'
		short3 'simd::short3'
		short4 'simd::short4'
		ushort2 'simd::ushort2'
		ushort3 'simd::ushort3'
		ushort4 'simd::ushort4'
		
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

{ #category : #testing }
SLVMMetalCodeGenerator >> emitPrelude [
	self
		emitLine: '#include <metal_stdlib>';
		emitLine: '#include <simd/simd.h>';
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

{ #category : #testing }
SLVMMetalCodeGenerator >> renameSymbol: aSymbol [
	^ RenamedSymbols at: aSymbol
]

{ #category : #testing }
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

{ #category : #visitor }
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

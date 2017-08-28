Class {
	#name : #SLVMCPPCodeGenerator,
	#superclass : #SLVMHighLevelLanguageCodeGenerator,
	#classVars : [
		'Keywords',
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
SLVMCPPCodeGenerator class >> codeGeneratorName [
	^ #cpp
]

{ #category : #'class initialization' }
SLVMCPPCodeGenerator class >> initialize [
	super initialize.
	self initializeKeywordSet.
	self initializeTypeMappings.
	self initializeTargetBuiltInMappings.
]

{ #category : #'class initialization' }
SLVMCPPCodeGenerator class >> initializeKeywordSet [
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

{ #category : #'class initialization' }
SLVMCPPCodeGenerator class >> initializeTargetBuiltInMappings [
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

		'sample.implicit_lod' (sample_implicit_lod call)
		
		#'math.acos'	(#'glm::acos' call)
		#'math.acosh'	(#'glm::acosh' call)
		#'math.asin'	(#'glm::asin' call)
		#'math.asinh'	(#'glm::asinh' call)
		#'math.atan2'	(#'glm::atan2' call)
		#'math.atan'	(#'glm::atan' call)
		#'math.atanh'	(#'glm::atanh' function)
		#'math.ceil'	(#'glm::ceil' function)
		#'math.cos'     (#'glm::cos' function)
		#'math.cosh'	(#'glm::cosh' call)
		#'math.degrees'	(#'glm::degrees' call)
		#'math.exp2'	(#'glm::exp2' call)
		#'math.exp'     (#'glm::exp' call)
		#'math.fabs'	(#'glm::abs' call)
		#'math.floor'	(#'glm::floor' call)
		#'math.fmax'	(#'glm::max' call)
		#'math.fmin'	(#'glm::min' call)
		#'math.fmix'	(#'glm::mix' call)
		#'math.fract'	(#'glm::fract' call)
		#'math.fsign'	(#'glm::fsign' call)
		#'math.inverseSqrt'	(#'glm::inverseSqrt' call)
		#'math.log2'	(#'glm::log2' call)
		#'math.log'	    (#'glm::log' call)
		#'math.pow'     (#'glm::pow' call)
		#'math.radians'	(#'glm::radians' call)
		#'math.roundEven'	(#'glm::roundEven' call)
		#'math.round'	(#'glm::round' call)
		#'math.sinh'	(#'glm::sinh' call)
		#'math.sin'     (#'glm::sin' call)
		#'math.smax'	(#'glm::max' call)
		#'math.smin'	(#'glm::min' call)
		#'math.smoothstep'	(#'glm::smoothstep' call)
		#'math.sqrt'	(#'glm::sqrt' call)
		#'math.step'	(#'glm::step' call)
		#'math.tan'	(#'glm::tan' call)
		#'math.trunc'	(#'glm::trunc' call)
		#'math.umax'	(#'glm::max' call)
		#'math.umin'	(#'glm::min' call)
		#'matrix.transpose'	(#'glm::transpose' call)
		#'vector.cross'     (#'glm::cross' call)
		#'vector.dot'	    (#'glm::dot' call)
		#'vector.length'	(#'glm::length' call)
		#'vector.normalize'	(#'glm::normalize' call)
		#'vector.reflect'	(#'glm::reflect' call)
		#'vector.refract'	(#'glm::refract' call)
	)
]

{ #category : #'class initialization' }
SLVMCPPCodeGenerator class >> initializeTypeMappings [
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
		doubleAlign4 double
		doubleAlign8 double
		float2 'glm::vec2'
		float3 'glm::vec3'
		float4 'glm::vec4'
		float2x2 'glm::mat2'
		float3x3 'glm::mat3'
		float4x4 'glm::mat4'
		
		int2 'glm::ivec2'
		int3 'glm::ivec3'
		int4 'glm::ivec4'
		uint2 'glm::uivec2'
		uint3 'glm::uivec3'
		uint4 'glm::uivec4'

		short2 'glm::svec2'
		short3 'glm::svec3'
		short4 'glm::svec4'
		ushort2 'glm::usvec2'
		ushort3 'glm::usvec3'
		ushort4 'glm::usvec4'
		
		texture2D 'texture2D'
		textureCube 'textureCube'
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
SLVMCPPCodeGenerator >> emitPrelude [
	linearAlgebraRequired ifTrue: [
		self
			emitLine: '#include <glm/glm.hpp>';
			emitNewline
	].

	dynamicRuntimeRequired ifTrue: [
		self
			emitLine: '#include <SLVM/DynamicRuntime.hpp>';
			emitNewline
	].

]

{ #category : #testing }
SLVMCPPCodeGenerator >> isBlackListedSymbol: aSymbol [
	^ Keywords includes: aSymbol
]

{ #category : #'code generation' }
SLVMCPPCodeGenerator >> mapBuiltInFunction: aFunctionName [
	TargetBuiltInMappings at: aFunctionName ifPresent: [ :mapping | ^ mapping ].
	^ super mapBuiltInFunction: aFunctionName
]

{ #category : #testing }
SLVMCPPCodeGenerator >> passGlobalsAsParameters [
	^ true
]

{ #category : #'code generation' }
SLVMCPPCodeGenerator >> translateBasicTypeName: aType [
	^ TypeDictionary at: aType
]

{ #category : #'code generation' }
SLVMCPPCodeGenerator >> translateHLFunctionDynamicLiteralNodeValue: literalNode [
	^ ByteString streamContents: [:out | out nextPutAll: 'literalAt('; print: literalNode index; nextPut: $) ]
]

{ #category : #'as yet unclassified' }
SLVMCPPCodeGenerator >> translateHLMessageSendStatementValue: statement [
	^ ByteString streamContents: [ :out |
		out nextPutAll: (statement receiver translateValueWith: self).
		out nextPutAll: '.send<'; nextPutAll: statement returnType name; nextPut: $>.
		out space; nextPut: $(.
		out nextPutAll: (statement selector translateValueWith: self).
		statement arguments doWithIndex: [ :arg :index |
			out nextPutAll: ', '.
			out nextPutAll: (arg translateValueWith: self)
		].
	
		out nextPut: $).
	]
]

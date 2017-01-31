Class {
	#name : #SLVMMetalCodeGenerator,
	#superclass : #SLVMHighLevelLanguageCodeGenerator,
	#instVars : [
		'ioVariableMapping',
		'forcedReturnValue'
	],
	#classVars : [
		'Keywords',
		'RenamedSymbols',
		'SamplerTypeDictionary',
		'SamplerTypeMapping',
		'SpecialSemanticVariableMap',
		'SpecialVariableLocationMapping',
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
	self initializeSpecialVariableMapping.
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
SLVMMetalCodeGenerator class >> initializeSpecialVariableMapping [
	SpecialVariableLocationMapping := Dictionary newFromPairs: #(
		-1 (position '[[position]]' false)
		-6 (_slvm_vertexID '[[vertex_id]]' true)
		-7 (_slvm_instanceID '[[instance_id]]' true)
	)
]

{ #category : #name }
SLVMMetalCodeGenerator class >> initializeStorageMap [
	StorageToAddressSpaceMap := Dictionary newFromPairs: #(
		uniform 'device const'
		uniformConstant 'constant const'
		pushConstant 'constant const'
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
		#'math.fsign'	(#'metal::sign' call)
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
		ushort 'unsigned short'
		int int
		uint 'unsigned int'
		long long
		ulong 'unsigned long'
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
		
		texture2D 'metal::texture2d<float>'
		textureCube 'metal::texturecube<float>'
		sampler 'metal::sampler'
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

{ #category : #visitor }
SLVMMetalCodeGenerator >> applyFunctionMetadata: function to: functionNode [
	function propertyAt: #fragment ifPresent: [
		functionNode shaderType: #fragment
	].

	function propertyAt: #vertex ifPresent: [
		functionNode shaderType: #vertex
	].

	function propertyAt: #compute ifPresent: [
		functionNode shaderType: #compute
	]	
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> dereferenceVariable: variable [
	| result |
	result := variable translateValueWith: self.
	variable isReferenceAsPointer ifTrue: [ ^ '(*' , result , ')' ].
	^ result
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> emitPrelude [
	self
		emitLine: '#include <metal_stdlib>';
		emitNewline
]

{ #category : #testing }
SLVMMetalCodeGenerator >> hasToCombineIOInStructure [
	^ true
]

{ #category : #initialization }
SLVMMetalCodeGenerator >> initialize [
	super initialize.
	ioVariableMapping := Dictionary new.
]

{ #category : #testing }
SLVMMetalCodeGenerator >> isBlackListedSymbol: aSymbol [
	^ Keywords includes: aSymbol
]

{ #category : #testing }
SLVMMetalCodeGenerator >> isGlobalInputPassedAsParameter: global [
	global type storage == #input ifTrue: [ 
		global propertyAt: #location ifPresent: [ :location |
			^ location < 0 and: [ (SpecialVariableLocationMapping at: location) third ]
		] 
	].
	^ false

]

{ #category : #testing }
SLVMMetalCodeGenerator >> isRenamedSymbol: aSymbol [
	^ RenamedSymbols includesKey: aSymbol
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> makeFunctionPrototypeString: function [
	| functionType argumentCount |
	^ ByteString streamContents: [:out |
		functionType := function type.
		function shaderType ifNotNil: [
			out
				nextPutAll: function shaderType; space;
				nextPutAll: self outputStructureName; space.		
		] ifNil: [ 
			out
				nextPutAll: functionType returnType name; space.
		].
			
		out
			nextPutAll: function name; space; nextPut: $(.
		argumentCount := 0.
		function arguments do: [ :arg |
			argumentCount > 0 ifTrue: [ out nextPutAll: ', ' ].
			out nextPutAll: arg type name; space; nextPutAll: arg name.
			argumentCount := argumentCount + 1.
		].
	
		function shaderType ifNotNil: [
			argumentCount > 0 ifTrue: [ out nextPutAll: ', ' ].
			out nextPutAll: self inputStructureName; space; nextPutAll: self stageInVariableName;
				nextPutAll: ' [[stage_in]]'.
			argumentCount := argumentCount + 1.
			
			function
				internedGlobals reject: [:global |
					(#(input output) includes: global variable storage)
					and: [ (self isGlobalInputPassedAsParameter: global value) not ]
				]
				thenDo: [ :global |
				argumentCount > 0 ifTrue: [ out nextPutAll: ', ' ].
				out nextPutAll: global type name; space; nextPutAll: (global variable name).
				out space; nextPutAll: (self shaderBindingForGlobal: global).
				argumentCount := argumentCount + 1.
			].
		] ifNil: [
			function internedGlobals do: [ :global |
				argumentCount > 0 ifTrue: [ out nextPutAll: ', ' ].
				out nextPutAll: global type name; space; nextPutAll: (global variable name).
				argumentCount := argumentCount + 1.
			].
		].
	
		out nextPut: $)
	]
]

{ #category : #testing }
SLVMMetalCodeGenerator >> mapBuiltInFunction: aFunctionName [
	TargetBuiltInMappings at: aFunctionName ifPresent: [ :mapping | ^ mapping ].
	^ super mapBuiltInFunction: aFunctionName
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> mapIOVar: var toField: field [
	| localStructureInstance |
	localStructureInstance := var type storage = #input ifTrue: [ self stageInVariableName ] ifFalse: [ self stageOutVariableName ]. 
	ioVariableMapping at: var put: ('&' , localStructureInstance , '.' , field name)
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> mapLocationBinding: location stage: stageKind variable: variable [
	(stageKind == #vertex and: [variable type storage = #input ]) ifTrue: [
		^'[[attribute(' , location asString , ')]]'
	].

	(stageKind == #fragment and: [variable type storage = #output ]) ifTrue: [
		^'[[color(' , location asString , ')]]'
	].

	^ nil
]

{ #category : #testing }
SLVMMetalCodeGenerator >> mapSpecialVariableLocation: location [
	^ SpecialVariableLocationMapping at: location
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
SLVMMetalCodeGenerator >> shaderBindingForGlobal: global [
	| storage value location |
	value := global value.
	storage := value value type storage.
	storage = #input ifTrue: [
		location := value propertyAt: #location ifAbsent: [ 
			self error: 'Input variable without location'.
		].
	
		^ (SpecialVariableLocationMapping at: location) second
	].

	^ ''
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> stageInVariableName [
	^ '_slvm_stagein'
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> stageOutVariableName [
	^ '_slvm_stageout'
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> translateBasicTypeName: aType [
	^ TypeDictionary at: aType
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> translateGlobalLocation: global [
	^ ''
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> translateGlobalVariableType: globalVariable [
	| valueType |
	valueType := globalVariable valueType.
	(valueType isSampledTextureType or: [ valueType isSamplerType or: [ valueType isTextureType or: [ self isGlobalInputPassedAsParameter: globalVariable ]]]) ifTrue: [
		^ self translateType: valueType
	].

	^ super translateGlobalVariableType: globalVariable
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
SLVMMetalCodeGenerator >> translateHLFunctionPrologue: function [
	forcedReturnValue := nil.
	function shaderType ifNil: [ ^ self ].
	
	forcedReturnValue := self stageOutVariableName. 
	self
		emitLine: self outputStructureName , ' ' , self stageOutVariableName, ';'.
	
	function internedGlobals
		select: [ :global | (#(input output) includes: global variable storage) and: [(self isGlobalInputPassedAsParameter: global value) not] ]
		thenDo: [ :global |
			self emitLine: ('{1} {2}{3} = {4};' format: { global type name . global variable name . global type arrayBounds: self unboundedArrayNotation . ioVariableMapping at: global value})
	]
]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> translateHLReturnVoid: statement [
	forcedReturnValue ifNotNil: [
		self emitLine: 'return ' , forcedReturnValue , ';'.
	] ifNil: [ 
		self emitLine: 'return;'
	]

]

{ #category : #'code generation' }
SLVMMetalCodeGenerator >> translateHLVariableDecl: variableDecl [
	| variableType arrayBounds variableTypeString binding |
	"Do not emit variables that have been interned."
	variableDecl needsInternation ifTrue: [ ^ self ].
	
	variableType := variableDecl type.
	arrayBounds := variableType arrayBounds: self unboundedArrayNotation.
	variableTypeString := variableType name.
	binding := variableDecl binding ifNil: [ '' ].

	self emitLine: ('{1} {2}{3}{4};' format: { variableTypeString . variableDecl name . arrayBounds . binding})

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

Class {
	#name : #SLVMGLSLCodeGenerator,
	#superclass : #SLVMHighLevelLanguageCodeGenerator,
	#classVars : [
		'Keywords',
		'SamplerTypeDictionary',
		'SamplerTypeMapping',
		'SpecialSemanticVariableMap',
		'TypeDictionary',
		'TypeMapping'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #name }
SLVMGLSLCodeGenerator class >> codeGeneratorName [
	^ #glsl
]

{ #category : #'class initialization' }
SLVMGLSLCodeGenerator class >> initialize [
	super initialize.
	self initializeKeywordSet.
	self initializeTypeMappings.
]

{ #category : #'class initialization' }
SLVMGLSLCodeGenerator class >> initializeKeywordSet [
		Keywords := Set newFrom: #(
		attribute const uniform varying
		layout
		
		centroid
patch
flat
smooth
noperspective
sample
break continue do for while
if
switch
case
default
else
subroutine
in out inout
float double
int void bool true false
invariant
discard return
mat2 mat3 mat4 dmat2 dmat3 dmat4
mat2x2 mat2x3 mat2x4 dmat2x2 dmat2x3 dmat2x4
mat3x2 mat3x3 mat3x4 dmat3x2 dmat3x3 dmat3x4
mat4x2 mat4x3 mat4x4 dmat4x2 dmat4x3 dmat4x4
vec2 vec3 vec4
uint
lowp
uvec2
ivec2 ivec3 ivec4
uvec3
bvec2 bvec3 bvec4
dvec2
dvec3
dvec4
uvec4
mediump highp
precision
sampler1D sampler2D sampler3D samplerCube
sampler1DShadow sampler2DShadow
samplerCubeShadow
sampler1DArray sampler2DArray
sampler1DArrayShadow sampler2DArrayShadow
isampler1D isampler2D isampler3D isamplerCube
isampler1DArray isampler2DArray
usampler1D usampler2D usampler3D usamplerCube
usampler1DArray usampler2DArray
sampler2DRect
sampler2DRectShadow
isampler2DRect
samplerBuffer isamplerBuffer usamplerBuffer
sampler2DMS isampler2DMS usampler2DMS
sampler2DMSArray
isampler2DMSArray
usampler2DRect
usampler2DMSArray
samplerCubeArray samplerCubeArrayShadow isamplerCubeArray usamplerCubeArray
struct

common partition
active
asm
class
union
enum typedef
template this packed
goto
inline
long
noinline
short
volatile
half
input output
hvec2 hvec3
fixed
hvec4
public
static
unsigned
fvec2
fvec3
extern
external
interface
superp
fvec4
sampler3DRect
filter
image1D image2D image3D imageCube
iimage1D iimage2D iimage3D iimageCube
uimage1D uimage2D uimage3D uimageCube
image1DArray image2DArray
iimage1DArray iimage2DArray
uimage1DArray
uimage2DArray
image1DShadow image2DShadow
image1DArrayShadow
imageBuffer
sizeof
image2DArrayShadow
iimageBuffer
uimageBuffer
cast
namespace
using
row_major
	).
]

{ #category : #'class initialization' }
SLVMGLSLCodeGenerator class >> initializeTypeMappings [
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
		float2 vec2
		float3 vec3
		float4 vec4
		float2x2 mat2
		float3x3 mat3
		float4x4 mat4
		
		int2 ivec2
		int3 ivec3
		int4 ivec4
		uint2 uivec2
		uint3 uivec3
		uint4 uivec4

		short2 svec2
		short3 svec3
		short4 svec4
		ushort2 usvec2
		ushort3 usvec3
		ushort4 usvec4
		
		texture2D texture2D
		textureCube textureCube
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

	SamplerTypeMapping pairsDo: [ :myName :mappedName |
		SamplerTypeDictionary at: (builtInTypes at: myName) put: mappedName
	].

	SpecialSemanticVariableMap := Dictionary newFromPairs: #(
		-1 gl_Position
	)
]

{ #category : #'code generation' }
SLVMGLSLCodeGenerator >> emitPrelude [
	self emitLine: '#version 400';
		emitLine: '#extension GL_ARB_separate_shader_objects : enable';
		emitLine: '#extension GL_ARB_shading_language_420pack : enable';
		emitNewline;
		emitLine: '#ifdef VULKAN';
		emitLine: '#define GL_BINDING_VK_SET_BINDING(glb, s, b) set = s, binding = b';
		emitLine: '#define VK_UNIFORM_SAMPLER(lc, name) layout lc uniform sampler name';
		emitLine: '#define COMBINE_SAMPLER_WITH(sampler, texture, samplerType) samplerType(sampler, texture)';
		emitLine: '#else';
		emitLine: '#define GL_BINDING_VK_SET_BINDING(glb, s, b) binding = glb';
		emitLine: '#define VK_UNIFORM_SAMPLER(lc, name) /* Declaration removed */';
		emitLine: '#define COMBINE_SAMPLER_WITH(sampler, texture, samplerType) texture';
		emitLine: '#endif';
		emitNewline.
]

{ #category : #'code generation' }
SLVMGLSLCodeGenerator >> generateInputOutputLayoutString: variable [
	| location |
	location := variable propertyAt: #location ifAbsent: [ ^ self ].
	^ 'layout ( location = ', location asString, ') '
]

{ #category : #'code generation' }
SLVMGLSLCodeGenerator >> generateUniformLayoutString: variable [
	^ ''
]

{ #category : #'as yet unclassified' }
SLVMGLSLCodeGenerator >> isBlackListedSymbol: aSymbol [
	^ Keywords includes: aSymbol
]

{ #category : #'code generation' }
SLVMGLSLCodeGenerator >> translateBasicTypeName: aType [
	^ TypeDictionary at: aType
]

{ #category : #'as yet unclassified' }
SLVMGLSLCodeGenerator >> translateHLStructure: structure [
	structure kind ~~ SLVMStructureType genericKind ifTrue: [ ^ self ].
	super translateHLStructure: structure.
]

{ #category : #'as yet unclassified' }
SLVMGLSLCodeGenerator >> translateHLVariableDecl: variableDecl [
	| storage variableType arrayBounds variableTypeString layout |
	storage := ''.
	layout := ''.
	variableDecl storage == SLVMType uniformStorage ifTrue: [
		variableDecl definition valueType isStructureType ifTrue: [ ^ self translateUniformBlock: variableDecl ].
		storage := 'uniform '.
		layout := self generateUniformLayoutString: variableDecl definition
	].

	variableDecl storage == SLVMType uniformConstantStorage ifTrue: [
		storage := 'uniform '.
		layout := self generateUniformLayoutString: variableDecl definition
	].

	variableDecl storage == SLVMType pushConstantStorage ifTrue: [
		storage := 'uniform '.
		layout := 'layout (push_constant) '.
	].

	variableDecl storage == SLVMType inputStorage ifTrue: [
		storage := 'in '.
		layout := self generateInputOutputLayoutString: variableDecl definition
	].

	variableDecl storage == SLVMType outputStorage ifTrue: [
		storage := 'out '.
		layout := self generateInputOutputLayoutString: variableDecl definition
	].

	variableType := variableDecl type.
	arrayBounds := variableType arrayBounds.
	variableTypeString := variableType name.

	self emitLine: ('{1}{2}{3} {4}{5};' format: { layout . storage . variableTypeString . variableDecl name . arrayBounds})
	
]

{ #category : #'as yet unclassified' }
SLVMGLSLCodeGenerator >> translateUniformBlock: blockDecl [
	| layout blockType structure |
	layout := self generateUniformLayoutString: blockDecl.
	blockType := 'uniform'.
	structure := blockDecl type.
	structure kind == SLVMStructureType bufferBlockKind ifTrue: [ blockType := 'buffer' ].
	self
		emitLine: ('{1}{2} {3}' format: { layout . blockType . blockDecl name });
		emitLine: '{';
		withExtraIndentationLevel: [
			structure fields do: [ :field | self translateHLVariableDecl: field ]
		];
		emitLine: ('} {1}' format: { blockDecl name });
		emitNewline.
]
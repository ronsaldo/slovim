Class {
	#name : #SLVMSampleExplicitLod,
	#superclass : #SLVMSampleInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMSampleExplicitLod class >> mnemonic [
	^ #sampleExplicitLOD
]

{ #category : #'as yet unclassified' }
SLVMSampleExplicitLod class >> sampledTexture: sampledTexture texcoord: texcoord lod: lod [
	^ self new sampledTexture: sampledTexture texcoord: texcoord lod: lod
]

{ #category : #visiting }
SLVMSampleExplicitLod >> accept: aVisitor [
	^ aVisitor visitSampleExplicitLod: self
]

{ #category : #'as yet unclassified' }
SLVMSampleExplicitLod >> lod [
	^ parameters third
]

{ #category : #'as yet unclassified' }
SLVMSampleExplicitLod >> sampledTexture: sampledTexture texcoord: texcoord lod: lod [
	| sampledTextureType |
	self parameters: { sampledTexture . texcoord . lod }.
	sampledTextureType := sampledTexture type.
	self assert: sampledTextureType isSampledTextureType.
	type := SLVMVectorType baseType: sampledTextureType texture sampledType elements: 4
]

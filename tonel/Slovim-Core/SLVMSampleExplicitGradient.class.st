Class {
	#name : #SLVMSampleExplicitGradient,
	#superclass : #SLVMSampleInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMSampleExplicitGradient class >> sampledTexture: sampledTexture texcoord: texcoord dtdx: dtdx dtdy: dtdy [
	^ self new sampledTexture: sampledTexture texcoord: texcoord dtdx: dtdx dtdy: dtdy
]

{ #category : #visitor }
SLVMSampleExplicitGradient >> accept: aVisitor [
	^ aVisitor visitSampleExplicitGradient: self
]

{ #category : #accessing }
SLVMSampleExplicitGradient >> dtdx [
	^ self parameters third
]

{ #category : #accessing }
SLVMSampleExplicitGradient >> dtdy [
	^ self parameters fourth
]

{ #category : #printing }
SLVMSampleExplicitGradient >> mnemonic [
	^ #sampleExplicitGradient
]

{ #category : #'as yet unclassified' }
SLVMSampleExplicitGradient >> sampledTexture: sampledTexture texcoord: texcoord dtdx: dtdx dtdy: dtdy [
	| sampledTextureType |
	self parameters: { sampledTexture . texcoord . dtdx . dtdy }.
	sampledTextureType := sampledTexture type.
	self assert: sampledTextureType isSampledTextureType.
	type := SLVMVectorType baseType: sampledTextureType texture sampledType elements: 4
]

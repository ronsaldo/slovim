Class {
	#name : #SLVMCombineSamplerWithTexture,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMCombineSamplerWithTexture class >> mnemonic [ 
	^ #combineSamplerWithTexture
]

{ #category : #construction }
SLVMCombineSamplerWithTexture class >> sampler: sampler texture: texture [
	^ self new sampler: sampler texture: texture
]

{ #category : #visitor }
SLVMCombineSamplerWithTexture >> accept: visitor [
	^ visitor visitCombineSamplerWithTexture: self
]

{ #category : #'as yet unclassified' }
SLVMCombineSamplerWithTexture >> createdWithMnemonic: theMnemonic decodedType: theDecodedType [
	super createdWithMnemonic: theMnemonic decodedType: theDecodedType.
	type := theDecodedType.
]

{ #category : #accessing }
SLVMCombineSamplerWithTexture >> sampler [
	^ parameters first
]

{ #category : #construction }
SLVMCombineSamplerWithTexture >> sampler: sampler texture: texture [
	self parameters: { sampler . texture }.
	self assert: sampler type isSamplerType.
	self assert: texture type isTextureType.
	type := SLVMSampledTextureType new texture: texture type.
]

{ #category : #accessing }
SLVMCombineSamplerWithTexture >> texture [
	^ parameters second
]

{ #category : #accessing }
SLVMCombineSamplerWithTexture >> type [
	^ type
]

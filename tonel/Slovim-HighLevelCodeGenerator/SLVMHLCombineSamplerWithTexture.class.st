Class {
	#name : #SLVMHLCombineSamplerWithTexture,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'sampler',
		'texture',
		'combinedType'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLCombineSamplerWithTexture >> combinedType [
	^ combinedType
]

{ #category : #accessing }
SLVMHLCombineSamplerWithTexture >> combinedType: anObject [
	combinedType := anObject
]

{ #category : #accessing }
SLVMHLCombineSamplerWithTexture >> sampler [
	^ sampler
]

{ #category : #accessing }
SLVMHLCombineSamplerWithTexture >> sampler: anObject [
	sampler := anObject
]

{ #category : #accessing }
SLVMHLCombineSamplerWithTexture >> texture [
	^ texture
]

{ #category : #accessing }
SLVMHLCombineSamplerWithTexture >> texture: anObject [
	texture := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLCombineSamplerWithTexture >> translateValueWith: translator [
	^ translator translateHLCombineSamplerWithTexture: self
]

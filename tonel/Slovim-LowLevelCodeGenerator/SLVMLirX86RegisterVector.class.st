Class {
	#name : #SLVMLirX86RegisterVector,
	#superclass : #SLVMLirX86Register,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterVector class >> canHoldValueOfType: type [
	^ type size <= 16 and: [
			(type isVectorType or:
			[ type isFloatType])
	]
]

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterVector >> isVectorRegister [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterVector >> size [
	^ 16
]

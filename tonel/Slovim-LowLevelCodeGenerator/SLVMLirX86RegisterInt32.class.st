Class {
	#name : #SLVMLirX86RegisterInt32,
	#superclass : #SLVMLirX86RegisterInt,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterInt32 class >> canHoldValueOfType: type [
	^ type size <= 4 and: [ type isScalarIntegerType ]
]

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterInt32 >> size [
	^ 4
]

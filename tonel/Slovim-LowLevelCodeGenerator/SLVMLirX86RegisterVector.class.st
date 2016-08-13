Class {
	#name : #SLVMLirX86RegisterVector,
	#superclass : #SLVMLirX86Register,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterVector class >> canHoldValueOfType: aValue forTarget: compilationTarget [
	^ (aValue sizeForTarget: compilationTarget) <= 16 and: [ aValue isMatrixType not ]
]

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterVector >> isVectorRegister [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterVector >> size [
	^ 16
]

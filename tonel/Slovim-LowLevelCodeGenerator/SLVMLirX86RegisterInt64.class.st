Class {
	#name : #SLVMLirX86RegisterInt64,
	#superclass : #SLVMLirX86RegisterInt,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterInt64 class >> canHoldValueOfType: type forTarget: compilationTarget [
	^ (type sizeForTarget: compilationTarget) <= 8 and: [
			(type isIntegerType or:
			[ type isReferenceType or:
			[ type isBooleanType ] ])
	]
]

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterInt64 >> size [
	^ 8
]

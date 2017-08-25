Class {
	#name : #SLVMUnionType,
	#superclass : #SLVMStructureType,
	#category : #'Slovim-Core-Type'
}

{ #category : #private }
SLVMUnionType >> computeLayout [
	alignment := 1.
	size := 0.
	offsets := types collect: [ :type |
		size := size max: type size.
		alignment := alignment max: type alignment.
		0
	].
	size := size alignedTo: alignment.
]

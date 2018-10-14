Class {
	#name : #SLVMPackedStructureType,
	#superclass : #SLVMStructureType,
	#category : #'Slovim-Core-Type'
}

{ #category : #private }
SLVMPackedStructureType >> accept: aVisitor [
	^ aVisitor visitPackedStructureType: self
]

{ #category : #private }
SLVMPackedStructureType >> computeLayout [
	| currentOffset offset |
	currentOffset := 0.
	alignment := 1.
	offsets := types collect: [ :type |
		offset := currentOffset.
		currentOffset := currentOffset + type size.
		offset.
	].
	size := currentOffset
]

{ #category : #testing }
SLVMPackedStructureType >> isPacked [
	^ true
]

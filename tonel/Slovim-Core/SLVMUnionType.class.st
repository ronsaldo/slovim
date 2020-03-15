Class {
	#name : #SLVMUnionType,
	#superclass : #SLVMStructureType,
	#category : #'Slovim-Core-Type'
}

{ #category : #printing }
SLVMUnionType class >> mnemonic [
	^ #union
]

{ #category : #private }
SLVMUnionType >> accept: aVisitor [
	^ aVisitor visitUnionType: self
]

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

{ #category : #testing }
SLVMUnionType >> isUnionType [
	^ true
]

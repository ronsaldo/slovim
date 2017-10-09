Class {
	#name : #SLVMETreeBitCast,
	#superclass : #SLVMETreeCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeBitCast >> accept: aVisitor [
	^ aVisitor visitBitCast: self
]

{ #category : #accessing }
SLVMETreeBitCast >> name [
	^ #bitcast
]

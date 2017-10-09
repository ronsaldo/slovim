Class {
	#name : #SLVMETreeFloatToIntCast,
	#superclass : #SLVMETreeCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeFloatToIntCast >> accept: aVisitor [
	^ aVisitor visitFloatToIntCast: self
]

{ #category : #visiting }
SLVMETreeFloatToIntCast >> name [
	^ #fp2int
]

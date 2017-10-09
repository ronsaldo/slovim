Class {
	#name : #SLVMETreeIntToFloatCast,
	#superclass : #SLVMETreeCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeIntToFloatCast >> accept: aVisitor [
	^ aVisitor visitIntToFloatCast: self
]

{ #category : #visiting }
SLVMETreeIntToFloatCast >> name [
	^ #int2fp
]

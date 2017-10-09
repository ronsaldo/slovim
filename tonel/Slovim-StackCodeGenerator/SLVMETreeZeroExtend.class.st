Class {
	#name : #SLVMETreeZeroExtend,
	#superclass : #SLVMETreeCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeZeroExtend >> accept: aVisitor [
	^ aVisitor visitZeroExtend: self
]

{ #category : #printing }
SLVMETreeZeroExtend >> name [
	^ #zext
]

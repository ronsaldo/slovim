Class {
	#name : #SLVMPharoIRTempVector,
	#superclass : #IRTempVector,
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #visiting }
SLVMPharoIRTempVector >> accept: aVisitor [
	^ aVisitor visitSLVMTempVector: self
]

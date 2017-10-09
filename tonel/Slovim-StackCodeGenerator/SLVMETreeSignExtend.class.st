Class {
	#name : #SLVMETreeSignExtend,
	#superclass : #SLVMETreeCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeSignExtend >> accept: aVisitor [
	^ aVisitor visitSignExtend: self
]

{ #category : #accessing }
SLVMETreeSignExtend >> name [
	^ #sext
]

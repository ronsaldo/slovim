Class {
	#name : #SLVMETreeTruncate,
	#superclass : #SLVMETreeCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeTruncate >> accept: aVisitor [
	^ aVisitor visitTruncate: self
]

{ #category : #printing }
SLVMETreeTruncate >> mnemonic [
	^ #truncate
]

{ #category : #printing }
SLVMETreeTruncate >> name [
	^ #truncate
]

Class {
	#name : #SLVMHLReturnVoidStatement,
	#superclass : #SLVMHLStatement,
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #'as yet unclassified' }
SLVMHLReturnVoidStatement >> isReturnVoid [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMHLReturnVoidStatement >> translateWith: translator [
	^ translator translateHLReturnVoid: self
]

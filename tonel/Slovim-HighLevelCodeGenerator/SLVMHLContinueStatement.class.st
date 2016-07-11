Class {
	#name : #SLVMHLContinueStatement,
	#superclass : #SLVMHLStatement,
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #converting }
SLVMHLContinueStatement >> translateWith: translator [
	^ translator translateHLContinueStatement: self
]

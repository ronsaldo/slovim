Class {
	#name : #SLVMHLBreakStatement,
	#superclass : #SLVMHLStatement,
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #converting }
SLVMHLBreakStatement >> translateWith: translator [
	^ translator translateHLBreakStatement: self
]

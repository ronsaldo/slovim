Class {
	#name : #SLVMHLContinueStatement,
	#superclass : #SLVMHLStatement,
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #testing }
SLVMHLContinueStatement >> isContinue [
	^ true
]

{ #category : #converting }
SLVMHLContinueStatement >> translateWith: translator [
	^ translator translateHLContinueStatement: self
]

Class {
	#name : #LLVMObject,
	#superclass : #Object,
	#category : #'LLVM-IR-Object'
}

{ #category : #'as yet unclassified' }
LLVMObject class >> enumDefine: list [
	| varName |
	list do: [ :element |
		varName := element first.
		(self hasClassVarNamed: varName) ifFalse: [ 
			self addClassVarNamed: varName
		].
		self classVarNamed: varName put: element
	].
]

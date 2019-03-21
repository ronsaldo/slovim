Class {
	#name : #SLVMMakeMatrix,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMMakeMatrix class >> type: matrixType parameters: arguments [
	^ self new type: matrixType parameters: arguments
]

{ #category : #visitor }
SLVMMakeMatrix >> accept: aVisitor [
	^ aVisitor visitMakeMatrix: self
]

{ #category : #testing }
SLVMMakeMatrix >> isPureInstruction [
	^ true
]

{ #category : #printing }
SLVMMakeMatrix >> mnemonic [
	^ #makeMatrix
]

{ #category : #accessing }
SLVMMakeMatrix >> type [
	^ type
]

{ #category : #construction }
SLVMMakeMatrix >> type: matrixType parameters: arguments [
	self parameters: arguments.
	type := matrixType.
	arguments do: [ :arg | self assert: arg type = matrixType columnType ].
]

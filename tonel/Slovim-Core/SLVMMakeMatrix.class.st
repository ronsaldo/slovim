Class {
	#name : #SLVMMakeMatrix,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMMakeMatrix class >> mnemonic [
	^ #makeMatrix
]

{ #category : #construction }
SLVMMakeMatrix class >> type: matrixType parameters: arguments [
	^ self new type: matrixType parameters: arguments
]

{ #category : #visitor }
SLVMMakeMatrix >> accept: aVisitor [
	^ aVisitor visitMakeMatrix: self
]

{ #category : #testing }
SLVMMakeMatrix >> isMakeMatrix [
	^ true
]

{ #category : #testing }
SLVMMakeMatrix >> isPureInstruction [
	^ true
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

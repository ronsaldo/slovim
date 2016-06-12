Class {
	#name : #SLVMMakeVector,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMMakeVector class >> type: vectorType parameters: arguments [
	^ self new type: vectorType parameters: arguments
]

{ #category : #visitor }
SLVMMakeVector >> accept: aVisitor [
	^ aVisitor visitMakeVector: self
]

{ #category : #printing }
SLVMMakeVector >> mnemonic [
	^ 'makeVector'
]

{ #category : #accessing }
SLVMMakeVector >> type [
	^ type
]

{ #category : #construction }
SLVMMakeVector >> type: vectorType parameters: arguments [
	self parameters: arguments.
	type := vectorType.
	arguments do: [ :arg | self assert: arg type = vectorType baseType ].
]

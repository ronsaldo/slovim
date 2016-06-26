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
	| countedArguments |
	self parameters: arguments.
	type := vectorType.
	countedArguments := 0.
	arguments do: [ :arg |
		arg type isVectorType ifTrue: [ 
			self assert: arg type baseType = vectorType baseType.
			countedArguments := countedArguments + arg type elements.
		] ifFalse: [
			self assert: arg type = vectorType baseType.
			countedArguments := countedArguments + 1.
		]
	].

	self assert: countedArguments = type elements.
]
Class {
	#name : #SLVMETreeExpression,
	#superclass : #SLVMETreeNode,
	#instVars : [
		'parameters',
		'type'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #printing }
SLVMETreeExpression >> fullPrintOn: aStream [
	self prettyPrintOn: aStream
]

{ #category : #initialization }
SLVMETreeExpression >> initialize [
	parameters := #()
]

{ #category : #testing }
SLVMETreeExpression >> isAlloca [
	^ false
]

{ #category : #testing }
SLVMETreeExpression >> isBranch [
	^ false
]

{ #category : #testing }
SLVMETreeExpression >> isLoad [
	^ false
]

{ #category : #testing }
SLVMETreeExpression >> isStore [
	^ false
]

{ #category : #testing }
SLVMETreeExpression >> isTerminator [
	^ false
]

{ #category : #accessing }
SLVMETreeExpression >> name [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMETreeExpression >> parameters [
	^ parameters
]

{ #category : #accessing }
SLVMETreeExpression >> parameters: anObject [
	parameters := anObject
]

{ #category : #printing }
SLVMETreeExpression >> prettyPrintOn: aStream [
	aStream nextPutAll: '('; putKeyword: self name.
	parameters do: [ :op |
		aStream space.
		op prettyPrintOn: aStream.
	].
	aStream nextPutAll: ')'
]

{ #category : #accessing }
SLVMETreeExpression >> type [
	^ type
]

{ #category : #accessing }
SLVMETreeExpression >> type: anObject [
	type := anObject
]

Class {
	#name : #SLVMETreeExpression,
	#superclass : #SLVMETreeValue,
	#instVars : [
		'parameters'
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

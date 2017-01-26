Class {
	#name : #SLVMHLArrayTypeNode,
	#superclass : #SLVMHLTypeNode,
	#instVars : [
		'name',
		'baseType',
		'elements'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #'as yet unclassified' }
SLVMHLArrayTypeNode >> arrayBounds: unboundedCase [
	| myBounds |
	myBounds := unboundedCase.
	elements ifNotNil: [ myBounds := '[', elements asString, ']'].
	^ (baseType arrayBounds: unboundedCase) , myBounds
]

{ #category : #accessing }
SLVMHLArrayTypeNode >> baseType [
	^ baseType
]

{ #category : #accessing }
SLVMHLArrayTypeNode >> baseType: anObject [
	baseType := anObject
]

{ #category : #accessing }
SLVMHLArrayTypeNode >> elements [
	^ elements
]

{ #category : #accessing }
SLVMHLArrayTypeNode >> elements: anObject [
	elements := anObject
]

{ #category : #accessing }
SLVMHLArrayTypeNode >> name [
	^ name
]

{ #category : #accessing }
SLVMHLArrayTypeNode >> name: anObject [
	name := anObject
]

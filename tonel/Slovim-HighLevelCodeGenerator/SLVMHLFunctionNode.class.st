Class {
	#name : #SLVMHLFunctionNode,
	#superclass : #SLVMHLCodeNode,
	#instVars : [
		'name',
		'type',
		'arguments'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #initialization }
SLVMHLFunctionNode >> initialize [
	super initialize.
	arguments := #()
]

{ #category : #accessing }
SLVMHLFunctionNode >> name [
	^ name
]

{ #category : #accessing }
SLVMHLFunctionNode >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMHLFunctionNode >> printOn: aStream [
	aStream nextPutAll: '(function '; print: name; space; print: type; nextPut: $)
]

{ #category : #'as yet unclassified' }
SLVMHLFunctionNode >> translateWith: translator [
	^ translator translateHLFunction: self
]

{ #category : #accessing }
SLVMHLFunctionNode >> type [
	^ type
]

{ #category : #accessing }
SLVMHLFunctionNode >> type: anObject [
	type := anObject
]

Class {
	#name : #SLVMHLFunctionArgumentNode,
	#superclass : #SLVMHLCodeNode,
	#instVars : [
		'name',
		'type'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #testing }
SLVMHLFunctionArgumentNode >> isReferenceAsPointer [
	^ type isReferenceType
]

{ #category : #accessing }
SLVMHLFunctionArgumentNode >> name [
	^ name
]

{ #category : #accessing }
SLVMHLFunctionArgumentNode >> name: anObject [
	name := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLFunctionArgumentNode >> translateValueWith: translator [
	^ translator translateHLFunctionArgumentNodeValue: self
]

{ #category : #accessing }
SLVMHLFunctionArgumentNode >> type [
	^ type
]

{ #category : #accessing }
SLVMHLFunctionArgumentNode >> type: anObject [
	type := anObject
]

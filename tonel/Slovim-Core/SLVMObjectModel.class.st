Class {
	#name : #SLVMObjectModel,
	#superclass : #SLVMObject,
	#instVars : [
		'target'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #'as yet unclassified' }
SLVMObjectModel >> convertConstantValue: value inModule: module [
	self halt
]

{ #category : #'literal conversion' }
SLVMObjectModel >> convertInlineLiteral: literal [
	^ SLVMConstantValue type: target dynamicObjectType value: literal
]

{ #category : #'literal conversion' }
SLVMObjectModel >> convertNonInlineLiteral: literal [
	^ literal
]

{ #category : #testing }
SLVMObjectModel >> isInlineLiteral: literal [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMObjectModel >> target [
	^ target
]

{ #category : #accessing }
SLVMObjectModel >> target: anObject [
	target := anObject
]

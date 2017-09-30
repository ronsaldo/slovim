Class {
	#name : #SLVMPharoFunctionTemp,
	#superclass : #SLVMPharoVariable,
	#instVars : [
		'name'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #accessing }
SLVMPharoFunctionTemp >> name [
	^ name
]

{ #category : #accessing }
SLVMPharoFunctionTemp >> name: anObject [
	name := anObject
]

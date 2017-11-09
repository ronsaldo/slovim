Class {
	#name : #SLVMPharoFunctionTemp,
	#superclass : #SLVMPharoVariable,
	#instVars : [
		'name',
		'location'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #accessing }
SLVMPharoFunctionTemp >> location [
	^ location
]

{ #category : #accessing }
SLVMPharoFunctionTemp >> location: anObject [
	location := anObject
]

{ #category : #accessing }
SLVMPharoFunctionTemp >> name [
	^ name
]

{ #category : #accessing }
SLVMPharoFunctionTemp >> name: anObject [
	name := anObject
]

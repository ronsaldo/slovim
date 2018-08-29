Class {
	#name : #SLVMPharoFunctionTemp,
	#superclass : #SLVMPharoVariable,
	#instVars : [
		'name',
		'vectorName',
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

{ #category : #accessing }
SLVMPharoFunctionTemp >> vectorName [
	^ vectorName
]

{ #category : #accessing }
SLVMPharoFunctionTemp >> vectorName: anObject [
	vectorName := anObject
]

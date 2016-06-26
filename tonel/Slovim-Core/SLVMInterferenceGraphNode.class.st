Class {
	#name : #SLVMInterferenceGraphNode,
	#superclass : #Object,
	#instVars : [
		'variable',
		'preferences',
		'interferences'
	],
	#category : #'Slovim-Core-RegisterAllocation'
}

{ #category : #initialization }
SLVMInterferenceGraphNode >> initialize [
	preferences := Set new.
	interferences := Set new.
]

{ #category : #accessing }
SLVMInterferenceGraphNode >> interferences [
	^ interferences
]

{ #category : #accessing }
SLVMInterferenceGraphNode >> preferences [
	^ preferences
]

{ #category : #'as yet unclassified' }
SLVMInterferenceGraphNode >> printOn: aStream [
	variable fullPrintOn: aStream
]

{ #category : #accessing }
SLVMInterferenceGraphNode >> variable [
	^ variable
]

{ #category : #accessing }
SLVMInterferenceGraphNode >> variable: anObject [
	variable := anObject
]

Class {
	#name : #SLVMInterferenceGraphNode,
	#superclass : #Object,
	#instVars : [
		'variable',
		'preferences',
		'interferences',
		'spillIndex',
		'spillLocation'
	],
	#category : #'Slovim-LowLevelCodeGenerator-RegisterAllocation'
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

{ #category : #'as yet unclassified' }
SLVMInterferenceGraphNode >> spillClass [
	^ variable type sizeAndAlignment
]

{ #category : #'as yet unclassified' }
SLVMInterferenceGraphNode >> spillClassForTarget: compilationTarget [
	^ variable type sizeAndAlignmentForTarget: compilationTarget
]

{ #category : #accessing }
SLVMInterferenceGraphNode >> spillIndex [
	^ spillIndex
]

{ #category : #accessing }
SLVMInterferenceGraphNode >> spillIndex: anObject [
	spillIndex := anObject
]

{ #category : #accessing }
SLVMInterferenceGraphNode >> variable [
	^ variable
]

{ #category : #accessing }
SLVMInterferenceGraphNode >> variable: anObject [
	variable := anObject
]

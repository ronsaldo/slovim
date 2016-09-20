"
I store the results of the liveness analyzer.

Currently I am undergoing a refactoring where the live sets are being replaced by a more compact bitmap.
"
Class {
	#name : #SLVMLivenessInformation,
	#superclass : #Object,
	#instVars : [
		'function',
		'liveVariables',
		'liveInBitmap',
		'liveOutBitmap',
		'liveInSets',
		'liveOutSets'
	],
	#category : #'Slovim-Core-Analysis'
}

{ #category : #accessing }
SLVMLivenessInformation >> function [
	^ function
]

{ #category : #accessing }
SLVMLivenessInformation >> function: anObject [
	function := anObject
]

{ #category : #accessing }
SLVMLivenessInformation >> liveInBitmap [
	^ liveInBitmap
]

{ #category : #accessing }
SLVMLivenessInformation >> liveInBitmap: anObject [
	liveInBitmap := anObject
]

{ #category : #accessing }
SLVMLivenessInformation >> liveInSets [
	^ liveInSets
]

{ #category : #accessing }
SLVMLivenessInformation >> liveInSets: anObject [
	liveInSets := anObject
]

{ #category : #accessing }
SLVMLivenessInformation >> liveOutBitmap [
	^ liveOutBitmap
]

{ #category : #accessing }
SLVMLivenessInformation >> liveOutBitmap: anObject [
	liveOutBitmap := anObject
]

{ #category : #accessing }
SLVMLivenessInformation >> liveOutSets [
	^ liveOutSets
]

{ #category : #accessing }
SLVMLivenessInformation >> liveOutSets: anObject [
	liveOutSets := anObject
]

{ #category : #accessing }
SLVMLivenessInformation >> liveVariables [
	^ liveVariables
]

{ #category : #accessing }
SLVMLivenessInformation >> liveVariables: anObject [
	liveVariables := anObject
]

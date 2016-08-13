Class {
	#name : #SLVMLivenessInformation,
	#superclass : #Object,
	#instVars : [
		'function',
		'liveInSets',
		'liveOutSets'
	],
	#category : #'Slovim-LowLevelCodeGenerator-RegisterAllocation'
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
SLVMLivenessInformation >> liveInSets [
	^ liveInSets
]

{ #category : #accessing }
SLVMLivenessInformation >> liveInSets: anObject [
	liveInSets := anObject
]

{ #category : #accessing }
SLVMLivenessInformation >> liveOutSets [
	^ liveOutSets
]

{ #category : #accessing }
SLVMLivenessInformation >> liveOutSets: anObject [
	liveOutSets := anObject
]

"
I represent a linear variable liveness range.
"
Class {
	#name : #SLVMLivenessRange,
	#superclass : #Object,
	#instVars : [
		'element',
		'start',
		'end',
		'register',
		'spillLocation',
		'spillRange',
		'activeRanges'
	],
	#category : #'Slovim-Core-Analysis'
}

{ #category : #accessing }
SLVMLivenessRange >> activeRanges [
	^ activeRanges
]

{ #category : #accessing }
SLVMLivenessRange >> activeRanges: anObject [
	activeRanges := anObject
]

{ #category : #accessing }
SLVMLivenessRange >> element [
	^ element
]

{ #category : #accessing }
SLVMLivenessRange >> element: anObject [
	element := anObject
]

{ #category : #accessing }
SLVMLivenessRange >> end [
	^ end
]

{ #category : #accessing }
SLVMLivenessRange >> end: anObject [
	end := anObject
]

{ #category : #testing }
SLVMLivenessRange >> isConsideredForRegisterAllocation [
	^ element isSSAValue and:
	[ element type size > 0 or:
		[ element isInstruction and: [
			element isCall or: [ element isMessageSend ] ] ] ]
]

{ #category : #testing }
SLVMLivenessRange >> isSSAValue [
	^ element isSSAValue
]

{ #category : #printing }
SLVMLivenessRange >> printOn: aStream [
	aStream print: element; space; print: start; space; print: end
]

{ #category : #accessing }
SLVMLivenessRange >> register [
	^ register
]

{ #category : #accessing }
SLVMLivenessRange >> register: anObject [
	register := anObject
]

{ #category : #accessing }
SLVMLivenessRange >> spillLocation [
	^ spillLocation
]

{ #category : #accessing }
SLVMLivenessRange >> spillLocation: anObject [
	spillLocation := anObject
]

{ #category : #accessing }
SLVMLivenessRange >> spillRange [
	^ spillRange
]

{ #category : #accessing }
SLVMLivenessRange >> spillRange: anObject [
	spillRange := anObject
]

{ #category : #accessing }
SLVMLivenessRange >> start [
	^ start
]

{ #category : #accessing }
SLVMLivenessRange >> start: anObject [
	start := anObject
]

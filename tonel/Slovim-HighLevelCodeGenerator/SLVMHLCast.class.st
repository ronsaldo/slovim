Class {
	#name : #SLVMHLCast,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'type',
		'argument'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLCast >> argument [
	^ argument
]

{ #category : #accessing }
SLVMHLCast >> argument: anObject [
	argument := anObject
]

{ #category : #converting }
SLVMHLCast >> translateValueWith: translator [
	^ translator translateHLCast: self
]

{ #category : #accessing }
SLVMHLCast >> type [
	^ type
]

{ #category : #accessing }
SLVMHLCast >> type: anObject [
	type := anObject
]

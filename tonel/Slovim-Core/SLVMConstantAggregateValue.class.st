Class {
	#name : #SLVMConstantAggregateValue,
	#superclass : #SLVMConstant,
	#instVars : [
		'type',
		'slots'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #testing }
SLVMConstantAggregateValue >> isConstantAggregateValue [
	^ true
]

{ #category : #copying }
SLVMConstantAggregateValue >> postCopy [
	slots := slots copy
]

{ #category : #accessing }
SLVMConstantAggregateValue >> slots [
	^ slots
]

{ #category : #accessing }
SLVMConstantAggregateValue >> slots: anObject [
	slots := anObject
]

{ #category : #accessing }
SLVMConstantAggregateValue >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantAggregateValue >> type: anObject [
	type := anObject
]

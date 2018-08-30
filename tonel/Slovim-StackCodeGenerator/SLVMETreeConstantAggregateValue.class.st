Class {
	#name : #SLVMETreeConstantAggregateValue,
	#superclass : #SLVMETreeConstant,
	#instVars : [
		'slots',
		'evaluationValue'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #testing }
SLVMETreeConstantAggregateValue >> isConstantAggregateValue [
	^ true
]

{ #category : #accessing }
SLVMETreeConstantAggregateValue >> slots [
	^ slots
]

{ #category : #accessing }
SLVMETreeConstantAggregateValue >> slots: anObject [
	slots := anObject
]

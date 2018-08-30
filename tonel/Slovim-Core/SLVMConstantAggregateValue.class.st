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

{ #category : #printing }
SLVMConstantAggregateValue >> mnemonic [
	self subclassResponsibility
]

{ #category : #copying }
SLVMConstantAggregateValue >> postCopy [
	slots := slots copy
]

{ #category : #printing }
SLVMConstantAggregateValue >> printOn: aStream [
	aStream nextPutAll: self mnemonic; space; print: type; space; nextPutAll: '{ '.
	slots doWithIndex: [ :s :i |
		i > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: s
	].

	aStream nextPutAll: ' }'.
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

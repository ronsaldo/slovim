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
SLVMConstantAggregateValue class >> isAbstract [
	^ self == SLVMConstantAggregateValue
]

{ #category : #printing }
SLVMConstantAggregateValue >> asSExpression [
	^ { self mnemonic . type asSExpression . slots collect: [ :each | each asSExpression ] as: Array }
]

{ #category : #'as yet unclassified' }
SLVMConstantAggregateValue >> extractValueAtIndices: indices [
	| result |
	result := self.
	1 to: indices size do: [ :i |
		result isConstantAggregateValue ifFalse: [
			self halt.
			^ { result . indices allButFirst: i - 1 }
		].
	
		result := result slots at: (indices at: i) + 1
	].

	^ { result . #() }
]

{ #category : #'as yet unclassified' }
SLVMConstantAggregateValue >> insertConstant: value atIndices: indices [
	| index result newSlotValue slotValue |
	index := indices first.

	newSlotValue := value.
	slotValue := slots at: index + 1.
	indices size > 1 ifTrue: [
		slotValue isConstantAggregateValue ifFalse: [ ^ nil ].
		newSlotValue := slotValue insertConstant: value atIndices: indices allButFirst.
	].

	slotValue = newSlotValue ifTrue: [ ^ self ].

	result := self copy.
	result slots at: index + 1 put: newSlotValue.
	^ result
]

{ #category : #testing }
SLVMConstantAggregateValue >> isConstantAggregateValue [
	^ true
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

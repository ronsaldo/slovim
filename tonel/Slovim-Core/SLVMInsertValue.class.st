Class {
	#name : #SLVMInsertValue,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'indices'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMInsertValue class >> aggregate: anAggregateValue value: value indices: indicesValue [
	^ self new aggregate: anAggregateValue value: value indices: indicesValue
]

{ #category : #visiting }
SLVMInsertValue >> accept: aVisitor [
	^ aVisitor visitInsertValue: self
]

{ #category : #accessing }
SLVMInsertValue >> aggregate [
	^ parameters first
]

{ #category : #'as yet unclassified' }
SLVMInsertValue >> aggregate: anAggregateValue value: value indices: newIndices [
	self assert: anAggregateValue type isAggregateType.
	indices := newIndices.
	self parameters: { anAggregateValue . value}.
	type := anAggregateValue type.
	self validate.
]

{ #category : #'basic optimizations' }
SLVMInsertValue >> foldConstant [
	| aggregate value newConstant |
	aggregate := self aggregate.
	value := self value.
	
	(aggregate isConstantAggregateValue and: [ value isConstant ]) ifTrue: [
		newConstant := aggregate insertConstant: value atIndices: indices.
		newConstant ifNotNil: [ ^ newConstant ]
	].

	^ self
]

{ #category : #printing }
SLVMInsertValue >> fullPrintOn: aStream [
	super fullPrintOn: aStream.
	indices do: [ :index |
		aStream nextPutAll: ' '; print: index
	]
]

{ #category : #accessing }
SLVMInsertValue >> indices [
	^ indices
]

{ #category : #testing }
SLVMInsertValue >> isInsertValue [
	^ true
]

{ #category : #testing }
SLVMInsertValue >> isPureInstruction [
	^ true
]

{ #category : #printing }
SLVMInsertValue >> mnemonic [
	^ #insertValue
]

{ #category : #accessing }
SLVMInsertValue >> signature [
	^ super signature , { indices }
]

{ #category : #accessing }
SLVMInsertValue >> type [
	^ type
]

{ #category : #'development support' }
SLVMInsertValue >> validate [
	| constantIndex currentType |
	currentType := type.
	indices do: [ :index |
		constantIndex := SLVMConstant type: type value: index.
		self assert: (currentType isMemberInBoundsAt: constantIndex).
		currentType := currentType typeOfMemberAt: constantIndex
	].

]

{ #category : #evaluating }
SLVMInsertValue >> value [
	^ parameters second
]

Class {
	#name : #SLVMExtractValue,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'indices'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMExtractValue class >> aggregate: anAggregateValue indices: indicesValue [
	^ self new aggregate: anAggregateValue indices: indicesValue
]

{ #category : #printing }
SLVMExtractValue >> accept: aVisitor [
	^ aVisitor visitExtractValue: self
]

{ #category : #accessing }
SLVMExtractValue >> aggregate [
	^ parameters first
]

{ #category : #'as yet unclassified' }
SLVMExtractValue >> aggregate: anAggregateValue indices: newIndices [
	self assert: anAggregateValue type isAggregateType.
	indices := newIndices.
	type := anAggregateValue type.
	indices do: [ :index | type := type typeOfMemberAt: (SLVMConstant type: type value: index) ].
	self parameters: { anAggregateValue }
]

{ #category : #printing }
SLVMExtractValue >> fullPrintOn: aStream [
	super fullPrintOn: aStream.
	indices do: [ :index |
		aStream nextPutAll: ' '; print: index
	]
]

{ #category : #accessing }
SLVMExtractValue >> indices [
	^ indices
]

{ #category : #'as yet unclassified' }
SLVMExtractValue >> isExtractValue [
	^ true
]

{ #category : #printing }
SLVMExtractValue >> mnemonic [
	^ 'extractValue'
]

{ #category : #accessing }
SLVMExtractValue >> type [
	^ type
]

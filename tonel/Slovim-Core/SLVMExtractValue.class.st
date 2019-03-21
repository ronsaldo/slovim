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
	| constantIndex |
	self assert: anAggregateValue type isAggregateType.
	indices := newIndices.
	type := anAggregateValue type.
	indices do: [ :index |
		constantIndex := SLVMConstant type: type value: index.
		self assert: (type isMemberInBoundsAt: constantIndex).
		type := type typeOfMemberAt: constantIndex
	].
	self parameters: { anAggregateValue }
]

{ #category : #testing }
SLVMExtractValue >> areIndices: currentIndices affectByModifiedIndices: modifiedIndices [
	modifiedIndices doWithIndex: [ :modifiedIndex :i |
		i > currentIndices size ifTrue: [ ^ false ].
		(currentIndices at: i) = modifiedIndex ifTrue: [ ^ true ]
	].

	^ false
]

{ #category : #'basic optimizations' }
SLVMExtractValue >> foldConstant [
	^ self foldConstantAt: self aggregate indices: indices
]

{ #category : #testing }
SLVMExtractValue >> foldConstantAt: currentAggregate indices: currentIndices [
	| newConstantAndIndices newConstant newIndices modifiedIndices |
	currentIndices ifEmpty: [ ^ currentAggregate ].

	currentAggregate isInstruction ifTrue: [
		"Merge extract values"
		currentAggregate isExtractValue ifTrue: [
			^ self foldConstantAt: currentAggregate aggregate indices: currentAggregate indices , currentIndices
		].
	
		"Look above the insert value."
		currentAggregate isInsertValue ifTrue: [
			modifiedIndices := currentAggregate indices.
			(currentIndices beginsWith: modifiedIndices) ifTrue: [
				^ self foldConstantAt: currentAggregate value indices: (currentIndices allButFirst: modifiedIndices size)
			] ifFalse: [
				(self areIndices: currentIndices affectByModifiedIndices: modifiedIndices) ifFalse: [ 
					^ self foldConstantAt: currentAggregate aggregate indices: currentIndices
				].		
			]
		].
	].

	currentAggregate isConstantAggregateValue ifTrue: [
		newConstantAndIndices := currentAggregate extractValueAtIndices: currentIndices.
		newConstant := newConstantAndIndices first.
		newIndices := newConstantAndIndices second.
		self aggregate == newConstant ifTrue: [ ^ self ].
		
		newIndices ifEmpty: [ 
			^ newConstant
		] ifNotEmpty: [
			self halt.
			^ SLVMExtractValue aggregate: newConstant indices: newIndices
		]
	].
 
	(currentAggregate ~~ self aggregate or: [ currentIndices ~~ indices ]) ifTrue: [ 
		^ SLVMExtractValue aggregate: currentAggregate indices: currentIndices 
	].

	^ self
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

{ #category : #testing }
SLVMExtractValue >> isPureInstruction [
	^ true
]

{ #category : #printing }
SLVMExtractValue >> mnemonic [
	^ #extractValue
]

{ #category : #accessing }
SLVMExtractValue >> signature [
	^ super signature , { indices }
]

{ #category : #accessing }
SLVMExtractValue >> type [
	^ type
]

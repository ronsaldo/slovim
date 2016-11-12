Class {
	#name : #SLVMLirStackFrame,
	#superclass : #Object,
	#instVars : [
		'localVariables',
		'alignment',
		'size',
		'arguments',
		'argumentsBaseOffset',
		'localsBaseOffset',
		'frameLessMethod',
		'argumentsSize',
		'dynamicRootCount',
		'reservedLocalsSpace'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #adding }
SLVMLirStackFrame >> addLocalReservedSpace: extraReservedSpace [
	reservedLocalsSpace := reservedLocalsSpace + extraReservedSpace
]

{ #category : #accessing }
SLVMLirStackFrame >> alignment [
	^ alignment
]

{ #category : #accessing }
SLVMLirStackFrame >> argumentsBaseOffset [
	^ argumentsBaseOffset
]

{ #category : #accessing }
SLVMLirStackFrame >> argumentsBaseOffset: anObject [
	argumentsBaseOffset := anObject
]

{ #category : #accessing }
SLVMLirStackFrame >> argumentsSize [
	^ argumentsSize
]

{ #category : #'as yet unclassified' }
SLVMLirStackFrame >> buildArgumentLayout [
	argumentsSize := 0.
	arguments do: [ :var |
		argumentsSize := argumentsSize alignedTo: var alignment.
		var offset: argumentsSize + argumentsBaseOffset.
		argumentsSize := argumentsSize + var size.
	].

]

{ #category : #'as yet unclassified' }
SLVMLirStackFrame >> buildLayout [
	self
		buildArgumentLayout;
		buildLocalLayout
]

{ #category : #'as yet unclassified' }
SLVMLirStackFrame >> buildLocalLayout [
	localVariables sort: [ :a :b |
		a dynamicRoot ~= b dynamicRoot ifTrue: [ 
			a dynamicRoot asBit > b dynamicRoot asBit
		] ifFalse: [ 
			a alignment < b alignment
		]
	].

	alignment := 1.
	size := reservedLocalsSpace.
	dynamicRootCount := 0.
	localVariables do: [ :var |
		var dynamicRoot ifTrue: [ 
			dynamicRootCount := dynamicRootCount + 1.
		].
	
		alignment := alignment max: var alignment.
		size := size alignedTo: var alignment.
		size := size + var size.
		var offset: (size - localsBaseOffset) negated.
	].

	(dynamicRootCount > 0 and: [dynamicRootCount ~= localVariables size ]) ifTrue: [
		"TODO: Ensure the dynamic roots come first"
		self halt.
	]

]

{ #category : #'as yet unclassified' }
SLVMLirStackFrame >> createArgument: argSize alignment: argAlignment [
	| result |
	result := SLVMLirStackFrameVariable new
		id: arguments size + 1;
		size: argSize;
		alignment: argAlignment;
		yourself.
	arguments add: result.
	^ result
]

{ #category : #'as yet unclassified' }
SLVMLirStackFrame >> createLocal: spillingClass [
	^ self createLocalSize: spillingClass first alignment: spillingClass second dynamicRoot: spillingClass third
]

{ #category : #'as yet unclassified' }
SLVMLirStackFrame >> createLocalSize: localSize alignment: localAlignment dynamicRoot: dynamicRoot [
	| result |
	result := SLVMLirStackFrameVariable new
		id: localVariables size + 1;
		size: localSize;
		alignment: localAlignment;
		dynamicRoot: dynamicRoot;
		yourself.
	localVariables add: result.
	^ result
]

{ #category : #accessing }
SLVMLirStackFrame >> dynamicRootCount [
	^ dynamicRootCount
]

{ #category : #accessing }
SLVMLirStackFrame >> frameLessMethod [
	^ frameLessMethod
]

{ #category : #accessing }
SLVMLirStackFrame >> frameLessMethod: anObject [
	frameLessMethod := anObject
]

{ #category : #initialization }
SLVMLirStackFrame >> initialize [
	localVariables := OrderedCollection new.
	arguments := OrderedCollection new.
	argumentsBaseOffset := 0.
	reservedLocalsSpace := 0.
	localsBaseOffset := 0.
	frameLessMethod := false.
]

{ #category : #accessing }
SLVMLirStackFrame >> localVariables [
	^ localVariables
]

{ #category : #accessing }
SLVMLirStackFrame >> localsBaseOffset [
	^ localsBaseOffset
]

{ #category : #accessing }
SLVMLirStackFrame >> localsBaseOffset: anObject [
	localsBaseOffset := anObject
]

{ #category : #optimizing }
SLVMLirStackFrame >> optimize [
	localVariables := localVariables select: #actuallyUsed
]

{ #category : #'as yet unclassified' }
SLVMLirStackFrame >> optimizeAndBuildLayout [
	self
		optimize;
		buildLayout
]

{ #category : #accessing }
SLVMLirStackFrame >> reservedLocalsSpace [
	^ reservedLocalsSpace
]

{ #category : #accessing }
SLVMLirStackFrame >> reservedLocalsSpace: anObject [
	reservedLocalsSpace := anObject
]

{ #category : #accessing }
SLVMLirStackFrame >> size [
	^ size
]

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
		'frameLessMethod'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

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

{ #category : #'as yet unclassified' }
SLVMLirStackFrame >> buildArgumentLayout [
	| argumentsSize |
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
	localVariables sort: [ :a :b | a alignment < b alignment ].
	alignment := 1.
	size := 0.
	localVariables do: [ :var |
		alignment := alignment max: var alignment.
		size := size alignedTo: var alignment.
		size := size + var size.
		var offset: size negated + localsBaseOffset.
	].

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
SLVMLirStackFrame >> size [
	^ size
]

Class {
	#name : #SLVMLirStackFrame,
	#superclass : #Object,
	#instVars : [
		'localVariables',
		'alignment',
		'size'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #accessing }
SLVMLirStackFrame >> alignment [
	^ alignment
]

{ #category : #'as yet unclassified' }
SLVMLirStackFrame >> buildLayout [
	localVariables sort: [ :a :b | a alignment < b alignment ].
	alignment := 1.
	size := 0.
	localVariables do: [ :var |
		alignment := alignment max: var alignment.
		size := size alignedTo: var alignment.
		size := size + var size.
		var offset: size negated.
	].
]

{ #category : #'as yet unclassified' }
SLVMLirStackFrame >> createLocal: sizeAndAlignment [
	^ self createLocalSize: sizeAndAlignment first alignment: sizeAndAlignment second
]

{ #category : #'as yet unclassified' }
SLVMLirStackFrame >> createLocalSize: size alignment: alignment [
	| result |
	result := SLVMLirStackFrameVariable new
		id: localVariables size + 1;
		size: size;
		alignment: alignment;
		yourself.
	localVariables add: result.
	^ result
]

{ #category : #initialization }
SLVMLirStackFrame >> initialize [
	localVariables := OrderedCollection new.
]

{ #category : #'as yet unclassified' }
SLVMLirStackFrame >> optimizeAndBuildLayout [
	self buildLayout
]

{ #category : #accessing }
SLVMLirStackFrame >> size [
	^ size
]

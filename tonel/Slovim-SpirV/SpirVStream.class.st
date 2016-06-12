Class {
	#name : #SpirVStream,
	#superclass : #Object,
	#instVars : [
		'out'
	],
	#pools : [
		'SpirVConstants'
	],
	#category : #'Slovim-SpirV'
}

{ #category : #accessing }
SpirVStream >> nextPut: aWord [
	out
		nextPut: aWord & 16rff;
		nextPut: (aWord >> 8) & 16rff;
		nextPut: (aWord >> 16) & 16rff;
		nextPut: (aWord >> 24) & 16rff.
]

{ #category : #accessing }
SpirVStream >> nextPutAll: aCollection [
	aCollection do: [ :el | self nextPut: el ]
]

{ #category : #accessing }
SpirVStream >> out [
	^ out
]

{ #category : #accessing }
SpirVStream >> out: anObject [
	out := anObject
]

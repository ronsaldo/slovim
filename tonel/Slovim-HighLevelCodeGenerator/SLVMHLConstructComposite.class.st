Class {
	#name : #SLVMHLConstructComposite,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'type',
		'arguments'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLConstructComposite >> arguments [
	^ arguments
]

{ #category : #accessing }
SLVMHLConstructComposite >> arguments: anObject [
	arguments := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLConstructComposite >> translateValueWith: translator [
	^ translator translateHLConstructComposite: self
]

{ #category : #accessing }
SLVMHLConstructComposite >> type [
	^ type
]

{ #category : #accessing }
SLVMHLConstructComposite >> type: anObject [
	type := anObject
]

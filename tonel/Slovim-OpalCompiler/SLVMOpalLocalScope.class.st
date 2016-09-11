Class {
	#name : #SLVMOpalLocalScope,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'parentScope',
		'selfValue',
		'variables'
	],
	#category : #'Slovim-OpalCompiler-Translator'
}

{ #category : #adding }
SLVMOpalLocalScope >> addValue: value symbol: symbol [
	variables at: symbol put: value
]

{ #category : #'as yet unclassified' }
SLVMOpalLocalScope >> includesSymbol: aSymbol [
	^ variables includesKey: aSymbol
]

{ #category : #initialization }
SLVMOpalLocalScope >> initialize [
	variables := Dictionary new.
]

{ #category : #'symbol lookup' }
SLVMOpalLocalScope >> lookSymbol: symbol [
	^ variables at: symbol
]

{ #category : #'symbol lookup' }
SLVMOpalLocalScope >> lookSymbol: symbol recursivelyWith: builder [
	variables at: symbol ifPresent: [ :result | ^ result ].
	parentScope ifNil: [ self error: 'failed to look variable.' ].
	^ parentScope lookSymbol: symbol recursivelyWith: builder

]

{ #category : #accessing }
SLVMOpalLocalScope >> parentScope [
	^ parentScope
]

{ #category : #accessing }
SLVMOpalLocalScope >> parentScope: anObject [
	parentScope := anObject
]

{ #category : #accessing }
SLVMOpalLocalScope >> selfValue [
	^ selfValue
]

{ #category : #accessing }
SLVMOpalLocalScope >> selfValue: anObject [
	selfValue := anObject
]

{ #category : #accessing }
SLVMOpalLocalScope >> variables [
	^ variables
]

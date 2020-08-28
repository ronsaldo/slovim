Class {
	#name : #MultiSpirVModule,
	#superclass : #Object,
	#instVars : [
		'modules',
		'moduleNameDictionary'
	],
	#pools : [
		'SpirVConstants'
	],
	#category : #'Slovim-SpirV'
}

{ #category : #'as yet unclassified' }
MultiSpirVModule >> moduleForEntryPointNamed: entryPointName [
	^ self moduleNameDictionary at: entryPointName
]

{ #category : #accessing }
MultiSpirVModule >> moduleNameDictionary [
	^ moduleNameDictionary ifNil: [
		moduleNameDictionary := Dictionary newFrom: (
			modules select: [ :each | each name isNotNil ] thenCollect: [ :each | each name -> each ]
		)
	]
]

{ #category : #accessing }
MultiSpirVModule >> modules [
	^ modules
]

{ #category : #accessing }
MultiSpirVModule >> modules: anObject [
	modules := anObject
]

{ #category : #'as yet unclassified' }
MultiSpirVModule >> saveTo: aFileReference [
	| zip |
	aFileReference exists ifTrue: [ aFileReference delete ].
	zip := ZipArchive new.
	modules do: [ :each |
		| fileName |
		self assert: each name isNotNil.
		fileName := (each name copyReplaceAll: ':' with: '_') , '.spv'.
		zip addString: each bytes asString as: fileName
	].

	zip writeToFile: aFileReference
]

Class {
	#name : #SpirVModuleEntryPointMetadata,
	#superclass : #Object,
	#instVars : [
		'stage',
		'name',
		'properties'
	],
	#pools : [
		'SpirVConstants'
	],
	#category : #'Slovim-SpirV'
}

{ #category : #accessing }
SpirVModuleEntryPointMetadata >> name [
	^ name
]

{ #category : #accessing }
SpirVModuleEntryPointMetadata >> name: anObject [
	name := anObject
]

{ #category : #accessing }
SpirVModuleEntryPointMetadata >> properties [
	^ properties
]

{ #category : #accessing }
SpirVModuleEntryPointMetadata >> properties: anObject [
	properties := anObject
]

{ #category : #accessing }
SpirVModuleEntryPointMetadata >> stage [
	^ stage
]

{ #category : #accessing }
SpirVModuleEntryPointMetadata >> stage: anObject [
	stage := anObject
]

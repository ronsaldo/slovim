Class {
	#name : #SLVMLirObjectModuleElementRelocation,
	#superclass : #SLVMLirObjectRelocation,
	#instVars : [
		'element'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Image'
}

{ #category : #accessing }
SLVMLirObjectModuleElementRelocation >> element [
	^ element
]

{ #category : #accessing }
SLVMLirObjectModuleElementRelocation >> element: anObject [
	element := anObject
]

{ #category : #'as yet unclassified' }
SLVMLirObjectModuleElementRelocation >> isModuleElementRelocation [
	^ true
]

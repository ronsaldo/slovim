Class {
	#name : #SLVMLirObjectRelocation,
	#superclass : #Object,
	#instVars : [
		'offset'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Image'
}

{ #category : #testing }
SLVMLirObjectRelocation >> isInternalRelocation [
	^ false
]

{ #category : #testing }
SLVMLirObjectRelocation >> isModuleElementRelocation [
	^ false
]

{ #category : #testing }
SLVMLirObjectRelocation >> isSpecialObjectRelocation [
	^ false
]

{ #category : #accessing }
SLVMLirObjectRelocation >> offset [
	^ offset
]

{ #category : #accessing }
SLVMLirObjectRelocation >> offset: anObject [
	offset := anObject
]

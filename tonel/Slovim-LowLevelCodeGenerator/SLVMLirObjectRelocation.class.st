Class {
	#name : #SLVMLirObjectRelocation,
	#superclass : #Object,
	#instVars : [
		'offset',
		'addend'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Image'
}

{ #category : #accessing }
SLVMLirObjectRelocation >> addend [
	^ addend
]

{ #category : #accessing }
SLVMLirObjectRelocation >> addend: anObject [
	addend := anObject
]

{ #category : #'as yet unclassified' }
SLVMLirObjectRelocation >> initialize [
	super initialize.
	addend := 0.
]

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

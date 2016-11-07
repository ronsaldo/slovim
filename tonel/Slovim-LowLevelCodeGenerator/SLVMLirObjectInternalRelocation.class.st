Class {
	#name : #SLVMLirObjectInternalRelocation,
	#superclass : #SLVMLirObjectRelocation,
	#instVars : [
		'target'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Image'
}

{ #category : #testing }
SLVMLirObjectInternalRelocation >> isInternalRelocation [
	^ true
]

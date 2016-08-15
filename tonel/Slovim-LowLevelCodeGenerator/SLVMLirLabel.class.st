Class {
	#name : #SLVMLirLabel,
	#superclass : #SLVMLirExternalLabel,
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #copying }
SLVMLirLabel >> copyReplaceBlocksWith: dict [
	^ dict at: self
]

{ #category : #initialization }
SLVMLirLabel >> initialize [
	super initialize.
	visibility := #private.
]

{ #category : #testing }
SLVMLirLabel >> isLabel [
	^ true
]

{ #category : #accessing }
SLVMLirLabel >> name [
	^ name
]

{ #category : #accessing }
SLVMLirLabel >> name: anObject [
	name := anObject
]

{ #category : #testing }
SLVMLirLabel >> value [
	^ offset
]

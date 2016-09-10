Class {
	#name : #SLVMLirLabelValue,
	#superclass : #SLVMLirInstructionStreamElement,
	#instVars : [
		'label'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #testing }
SLVMLirLabelValue >> isLabelValue [
	^ true
]

{ #category : #accessing }
SLVMLirLabelValue >> label [
	^ label
]

{ #category : #accessing }
SLVMLirLabelValue >> label: anObject [
	label := anObject
]

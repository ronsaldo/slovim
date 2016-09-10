Class {
	#name : #SLVMLirLabelContentEnd,
	#superclass : #SLVMLirInstructionStreamElement,
	#instVars : [
		'label'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #'as yet unclassified' }
SLVMLirLabelContentEnd >> isLabelContentEnd [
	^ true
]

{ #category : #accessing }
SLVMLirLabelContentEnd >> label [
	^ label
]

{ #category : #accessing }
SLVMLirLabelContentEnd >> label: anObject [
	label := anObject
]

{ #category : #'as yet unclassified' }
SLVMLirLabelContentEnd >> printOnInstructionStream: aStream [
	aStream nextPutAll: 'end of '; print: label
]

{ #category : #'as yet unclassified' }
SLVMLirLabelContentEnd >> size [
	^ 0
]

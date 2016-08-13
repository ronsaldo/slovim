Class {
	#name : #SLVMLirImmediate,
	#superclass : #SLVMLirInstructionOperand,
	#instVars : [
		'value'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #'as yet unclassified' }
SLVMLirImmediate >> isImmediate [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMLirImmediate >> isSmallImmediate [
	^ value between: -128 and: 127
]

{ #category : #'as yet unclassified' }
SLVMLirImmediate >> printOn: aStream [
	aStream nextPutAll: 'imm '; print: value
]

{ #category : #accessing }
SLVMLirImmediate >> value [
	^ value
]

{ #category : #accessing }
SLVMLirImmediate >> value: anObject [
	value := anObject
]

Class {
	#name : #SLVMLirImmediate,
	#superclass : #SLVMLirInstructionOperand,
	#instVars : [
		'value'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #testing }
SLVMLirImmediate >> isImmediate [
	^ true
]

{ #category : #testing }
SLVMLirImmediate >> isImmediateConstant [
	^ true
]

{ #category : #testing }
SLVMLirImmediate >> isImmediateInInt32Range [
	^ value between: -2147483648 and: 2147483647
]

{ #category : #testing }
SLVMLirImmediate >> isSmallImmediate [
	^ value between: -128 and: 127
]

{ #category : #printing }
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

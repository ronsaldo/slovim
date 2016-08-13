Class {
	#name : #SLVMLirStackFrameVariable,
	#superclass : #SLVMLirInstructionOperand,
	#instVars : [
		'id',
		'offset',
		'size',
		'alignment'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #accessing }
SLVMLirStackFrameVariable >> alignment [
	^ alignment
]

{ #category : #accessing }
SLVMLirStackFrameVariable >> alignment: anObject [
	alignment := anObject
]

{ #category : #accessing }
SLVMLirStackFrameVariable >> id [
	^ id
]

{ #category : #accessing }
SLVMLirStackFrameVariable >> id: anObject [
	id := anObject
]

{ #category : #testing }
SLVMLirStackFrameVariable >> isStackFrameVariable [
	^ true
]

{ #category : #accessing }
SLVMLirStackFrameVariable >> offset [
	^ offset
]

{ #category : #accessing }
SLVMLirStackFrameVariable >> offset: anObject [
	offset := anObject
]

{ #category : #printing }
SLVMLirStackFrameVariable >> printOn: aStream [
	aStream nextPutAll: 'local@'; print: offset
]

{ #category : #accessing }
SLVMLirStackFrameVariable >> size [
	^ size
]

{ #category : #accessing }
SLVMLirStackFrameVariable >> size: anObject [
	size := anObject
]

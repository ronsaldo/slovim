Class {
	#name : #SLVMLirStackFrameVariable,
	#superclass : #SLVMLirInstructionOperand,
	#instVars : [
		'id',
		'offset',
		'size',
		'alignment',
		'actuallyUsed',
		'dynamicRoot'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #accessing }
SLVMLirStackFrameVariable >> actuallyUsed [
	^ actuallyUsed
]

{ #category : #accessing }
SLVMLirStackFrameVariable >> actuallyUsed: anObject [
	actuallyUsed := anObject
]

{ #category : #accessing }
SLVMLirStackFrameVariable >> alignment [
	^ alignment
]

{ #category : #accessing }
SLVMLirStackFrameVariable >> alignment: anObject [
	alignment := anObject
]

{ #category : #converting }
SLVMLirStackFrameVariable >> asX86PtrOfSize: newSize [
	size = newSize ifTrue: [ ^ self ].
	self halt.
]

{ #category : #accessing }
SLVMLirStackFrameVariable >> dynamicRoot [
	^ dynamicRoot
]

{ #category : #accessing }
SLVMLirStackFrameVariable >> dynamicRoot: anObject [
	dynamicRoot := anObject
]

{ #category : #accessing }
SLVMLirStackFrameVariable >> id [
	^ id
]

{ #category : #accessing }
SLVMLirStackFrameVariable >> id: anObject [
	id := anObject
]

{ #category : #initialization }
SLVMLirStackFrameVariable >> initialize [
	super initialize.
	actuallyUsed := false.
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

{ #category : #accessing }
SLVMLirStackFrameVariable >> spillClass [
	^ { size . alignment . dynamicRoot }
]

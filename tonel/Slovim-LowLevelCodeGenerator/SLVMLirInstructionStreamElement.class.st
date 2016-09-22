Class {
	#name : #SLVMLirInstructionStreamElement,
	#superclass : #SLVMLirInstructionOperand,
	#instVars : [
		'section',
		'size',
		'offset',
		'previous',
		'next'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #accessing }
SLVMLirInstructionStreamElement >> alignment [
	^ 1
]

{ #category : #testing }
SLVMLirInstructionStreamElement >> isInstruction [
	^ false
]

{ #category : #accessing }
SLVMLirInstructionStreamElement >> next [
	^ next
]

{ #category : #accessing }
SLVMLirInstructionStreamElement >> next: anObject [
	next := anObject
]

{ #category : #accessing }
SLVMLirInstructionStreamElement >> offset [
	^ offset
]

{ #category : #accessing }
SLVMLirInstructionStreamElement >> offset: anObject [
	offset := anObject
]

{ #category : #accessing }
SLVMLirInstructionStreamElement >> previous [
	^ previous
]

{ #category : #accessing }
SLVMLirInstructionStreamElement >> previous: anObject [
	previous := anObject
]

{ #category : #printing }
SLVMLirInstructionStreamElement >> printOnInstructionStream: aStream [
	self printOn: aStream
]

{ #category : #removing }
SLVMLirInstructionStreamElement >> removeFromStream [
	section removeElement: self
]

{ #category : #accessing }
SLVMLirInstructionStreamElement >> section [
	^ section
]

{ #category : #accessing }
SLVMLirInstructionStreamElement >> section: anObject [
	section := anObject
]

{ #category : #accessing }
SLVMLirInstructionStreamElement >> size [
	^ size
]

{ #category : #accessing }
SLVMLirInstructionStreamElement >> size: anObject [
	size := anObject
]

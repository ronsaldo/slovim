Class {
	#name : #SLVMLirInstructionStreamElement,
	#superclass : #SLVMLirInstructionOperand,
	#instVars : [
		'stream',
		'size',
		'offset',
		'previous',
		'next'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

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

{ #category : #'as yet unclassified' }
SLVMLirInstructionStreamElement >> printOnInstructionStream: aStream [
	self printOn: aStream
]

{ #category : #'as yet unclassified' }
SLVMLirInstructionStreamElement >> removeFromStream [
	stream removeElement: self
]

{ #category : #accessing }
SLVMLirInstructionStreamElement >> size [
	^ size
]

{ #category : #accessing }
SLVMLirInstructionStreamElement >> size: anObject [
	size := anObject
]

{ #category : #accessing }
SLVMLirInstructionStreamElement >> stream [
	^ stream
]

{ #category : #accessing }
SLVMLirInstructionStreamElement >> stream: anObject [
	stream := anObject
]

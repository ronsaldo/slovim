Class {
	#name : #SLVMHLMessageSendStatement,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'returnType',
		'selector',
		'receiver',
		'arguments'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLMessageSendStatement >> arguments [
	^ arguments
]

{ #category : #accessing }
SLVMHLMessageSendStatement >> arguments: anObject [
	arguments := anObject
]

{ #category : #accessing }
SLVMHLMessageSendStatement >> receiver [
	^ receiver
]

{ #category : #accessing }
SLVMHLMessageSendStatement >> receiver: anObject [
	receiver := anObject
]

{ #category : #accessing }
SLVMHLMessageSendStatement >> returnType [
	^ returnType
]

{ #category : #accessing }
SLVMHLMessageSendStatement >> returnType: anObject [
	returnType := anObject
]

{ #category : #accessing }
SLVMHLMessageSendStatement >> selector [
	^ selector
]

{ #category : #accessing }
SLVMHLMessageSendStatement >> selector: anObject [
	selector := anObject
]

{ #category : #converting }
SLVMHLMessageSendStatement >> translateValueWith: translator [
	^ translator translateHLMessageSendStatementValue: self
]

{ #category : #converting }
SLVMHLMessageSendStatement >> translateWith: translator [
	^ translator translateHLMessageSendStatement: self
]

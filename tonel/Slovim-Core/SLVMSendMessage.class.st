Class {
	#name : #SLVMSendMessage,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'instance creation' }
SLVMSendMessage class >> returnType: returnType receiver: receiver selector: selector arguments: arguments [
	^ self new returnType: returnType receiver: receiver selector: selector arguments: arguments
]

{ #category : #'as yet unclassified' }
SLVMSendMessage >> accept: aVisitor [
	^ aVisitor visitMessageSend: self
]

{ #category : #accessing }
SLVMSendMessage >> arguments [
	^ parameters allButFirst: 2
]

{ #category : #testing }
SLVMSendMessage >> isMessageSend [
	^ true
]

{ #category : #printing }
SLVMSendMessage >> mnemonic [
	^ 'send'
]

{ #category : #accessing }
SLVMSendMessage >> receiver [
	^ parameters first
]

{ #category : #'instance creation' }
SLVMSendMessage >> returnType: returnType receiver: receiver selector: selector arguments: arguments [
	self parameters: { receiver . selector } , arguments.
	self assert: receiver type isDynamicObjectType.
	self assert: selector type isDynamicObjectType.
	type := returnType.
]

{ #category : #accessing }
SLVMSendMessage >> selector [
	^ parameters second
]

{ #category : #accessing }
SLVMSendMessage >> type [
	^ type
]

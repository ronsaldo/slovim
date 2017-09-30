Class {
	#name : #SLVMETreeMessageSendExpression,
	#superclass : #SLVMETreeExpression,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeMessageSendExpression >> accept: aVisitor [
	^ aVisitor visitMessageSend: self
]

{ #category : #accessing }
SLVMETreeMessageSendExpression >> arguments [
	^ parameters allButFirst: 2
]

{ #category : #accessing }
SLVMETreeMessageSendExpression >> name [
	^ #send
]

{ #category : #accessing }
SLVMETreeMessageSendExpression >> receiver [
	^ parameters first
]

{ #category : #accessing }
SLVMETreeMessageSendExpression >> selector [
	^ parameters second
]

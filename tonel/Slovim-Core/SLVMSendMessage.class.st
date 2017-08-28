Class {
	#name : #SLVMSendMessage,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'flags'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'instance creation' }
SLVMSendMessage class >> returnType: returnType receiver: receiver selector: selector arguments: arguments [
	^ self new returnType: returnType receiver: receiver selector: selector arguments: arguments
]

{ #category : #visitor }
SLVMSendMessage >> accept: aVisitor [
	^ aVisitor visitMessageSend: self
]

{ #category : #adding }
SLVMSendMessage >> addFlag: flag [
	flags := flags copyWith: flag
	
]

{ #category : #accessing }
SLVMSendMessage >> arguments [
	^ parameters allButFirst: 2
]

{ #category : #testing }
SLVMSendMessage >> hasFlag: flag [
	^ flags includes: flag
	
]

{ #category : #initialization }
SLVMSendMessage >> initialize [
	super initialize.
	flags := #().
	
]

{ #category : #testing }
SLVMSendMessage >> isDynamicObjectReferenceCreator [
	^ true
]

{ #category : #testing }
SLVMSendMessage >> isMessageSend [
	^ true
]

{ #category : #testing }
SLVMSendMessage >> isSuperSend [
	^ self hasFlag: #superSend
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

{ #category : #initialization }
SLVMSendMessage >> setSuperSend [
	self addFlag: #superSend
]

{ #category : #accessing }
SLVMSendMessage >> type [
	^ type
]

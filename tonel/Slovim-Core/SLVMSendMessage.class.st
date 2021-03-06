Class {
	#name : #SLVMSendMessage,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'highLevelMessageSendFunctionType'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMSendMessage class >> mnemonic [
	^ #send
]

{ #category : #'instance creation' }
SLVMSendMessage class >> returnType: returnType receiver: receiver selector: selector arguments: arguments [
	^ self new returnType: returnType receiver: receiver selector: selector arguments: arguments
]

{ #category : #visitor }
SLVMSendMessage >> accept: aVisitor [
	^ aVisitor visitMessageSend: self
]

{ #category : #accessing }
SLVMSendMessage >> arguments [
	^ parameters allButFirst: 2
]

{ #category : #accessing }
SLVMSendMessage >> callingConvention [
	^ SLVMFunctionType smalltalkCallingConvention
]

{ #category : #'as yet unclassified' }
SLVMSendMessage >> createdWithMnemonic: theMnemonic decodedType: theDecodedType [
	super createdWithMnemonic: theMnemonic decodedType: theDecodedType.
	type := theDecodedType.
]

{ #category : #testing }
SLVMSendMessage >> hasSRet [
	^ self hasFlag: #sret
]

{ #category : #accessing }
SLVMSendMessage >> highLevelMessageSendFunctionType [
	^ highLevelMessageSendFunctionType
]

{ #category : #accessing }
SLVMSendMessage >> highLevelMessageSendFunctionType: anObject [
	highLevelMessageSendFunctionType := anObject
]

{ #category : #testing }
SLVMSendMessage >> isDoesNotUnderstandMessage [
	| selector |
	selector := self selector.
	(selector isInstruction and: [selector isBitCast]) ifTrue: [ selector := selector source ]..

	^ selector isConstant and: [selector isFunctionDynamicLiteral and: [ selector value == #doesNotUnderstand: ]]
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

{ #category : #accessing }
SLVMSendMessage >> receiver [
	^ parameters first
]

{ #category : #'instance creation' }
SLVMSendMessage >> returnType: returnType receiver: receiver selector: selector arguments: arguments [
	self parameters: { receiver . selector } , arguments.
	self assert: receiver type isDynamicObjectPointerType.
	self assert: selector type isDynamicObjectPointerType.
	type := returnType.
]

{ #category : #accessing }
SLVMSendMessage >> selector [
	^ parameters second
]

{ #category : #accessing }
SLVMSendMessage >> sendDispatchTrampolineType [
	highLevelMessageSendFunctionType ifNotNil: [ ^ highLevelMessageSendFunctionType ].
	^ SLVMFunctionType callingConvention: self callingConvention
		arguments: {self receiver type asGenericMessageType} , (self arguments collect: [:arg | arg type asGenericMessageType]) returnType: type asGenericMessageType
]

{ #category : #testing }
SLVMSendMessage >> setSRetPresence [
	^ self addFlag: #sret
]

{ #category : #initialization }
SLVMSendMessage >> setSuperSend [
	self addFlag: #superSend
]

{ #category : #accessing }
SLVMSendMessage >> type [
	^ type
]

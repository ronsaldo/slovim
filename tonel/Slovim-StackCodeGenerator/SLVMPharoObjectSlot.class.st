Class {
	#name : #SLVMPharoObjectSlot,
	#superclass : #SLVMPharoVariable,
	#instVars : [
		'pointer',
		'slotIndex'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #'as yet unclassified' }
SLVMPharoObjectSlot >> emitPushWith: aCodeGenerator [
	self isReceiverSlot ifTrue: [
		^ aCodeGenerator pushInstVar: slotIndex + 1
	] ifFalse: [ 
		self halt
	]
]

{ #category : #'as yet unclassified' }
SLVMPharoObjectSlot >> emitStoreStackTopWith: aCodeGenerator [
	self isReceiverSlot ifTrue: [
		^ aCodeGenerator storeInstVar: slotIndex + 1
	] ifFalse: [ 
		self halt
	]
]

{ #category : #testing }
SLVMPharoObjectSlot >> isReceiverSlot [
	^ pointer isFunctionArgument and: [ pointer isReceiver ]
]

{ #category : #accessing }
SLVMPharoObjectSlot >> pointer [
	^ pointer
]

{ #category : #accessing }
SLVMPharoObjectSlot >> pointer: anObject [
	pointer := anObject
]

{ #category : #accessing }
SLVMPharoObjectSlot >> slotIndex [
	^ slotIndex
]

{ #category : #accessing }
SLVMPharoObjectSlot >> slotIndex: anObject [
	slotIndex := anObject
]

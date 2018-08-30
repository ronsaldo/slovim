Class {
	#name : #SLVMGetFramePointer,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMGetFramePointer class >> type: type [
	^ self new type: type
]

{ #category : #visitor }
SLVMGetFramePointer >> accept: visitor [
	^ visitor visitGetFramePointer: self
]

{ #category : #testing }
SLVMGetFramePointer >> isPureInstruction [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMGetFramePointer >> mnemonic [
	^ 'getFramePointer'
]

{ #category : #accessing }
SLVMGetFramePointer >> type [
	^ type
]

{ #category : #accessing }
SLVMGetFramePointer >> type: anObject [
	type := anObject.
	self assert: type isPointerType.
	
]

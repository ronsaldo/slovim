Class {
	#name : #SLVMDebugType,
	#superclass : #SLVMDebugScope,
	#instVars : [
		'kind',
		'bitSize',
		'bitAlignment'
	],
	#category : #'Slovim-Core-Debug'
}

{ #category : #accessing }
SLVMDebugType >> bitAlignment [
	^ bitAlignment
]

{ #category : #accessing }
SLVMDebugType >> bitAlignment: anObject [
	bitAlignment := anObject
]

{ #category : #accessing }
SLVMDebugType >> bitSize [
	^ bitSize
]

{ #category : #accessing }
SLVMDebugType >> bitSize: anObject [
	bitSize := anObject
]

{ #category : #'attributes setters' }
SLVMDebugType >> byteAlignment: aSize [
	bitAlignment := aSize * 8
]

{ #category : #'attributes setters' }
SLVMDebugType >> byteSize: aSize [
	bitSize := aSize * 8
]

{ #category : #accessing }
SLVMDebugType >> kind [
	^ kind
]

{ #category : #accessing }
SLVMDebugType >> kind: anObject [
	kind := anObject
]

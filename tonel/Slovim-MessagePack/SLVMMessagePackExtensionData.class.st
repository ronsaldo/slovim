Class {
	#name : #SLVMMessagePackExtensionData,
	#superclass : #Object,
	#instVars : [
		'data',
		'type'
	],
	#category : #'Slovim-MessagePack-Encoder'
}

{ #category : #'as yet unclassified' }
SLVMMessagePackExtensionData class >> data: data type: type [
	^ self new data: data; type: type; yourself
]

{ #category : #'as yet unclassified' }
SLVMMessagePackExtensionData >> asSLVMMessagePackSerializableObject [
	^ self
]

{ #category : #accessing }
SLVMMessagePackExtensionData >> data [
	^ data
]

{ #category : #accessing }
SLVMMessagePackExtensionData >> data: anObject [
	data := anObject
]

{ #category : #'as yet unclassified' }
SLVMMessagePackExtensionData >> slvmMessagePackEncodeWith: encoder [
	encoder encodeExtension: data type: type
]

{ #category : #accessing }
SLVMMessagePackExtensionData >> type [
	^ type
]

{ #category : #accessing }
SLVMMessagePackExtensionData >> type: anObject [
	type := anObject
]

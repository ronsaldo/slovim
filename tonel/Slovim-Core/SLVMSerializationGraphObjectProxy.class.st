Class {
	#name : #SLVMSerializationGraphObjectProxy,
	#superclass : #Object,
	#instVars : [
		'id',
		'object',
		'type',
		'earlyFields',
		'fields'
	],
	#category : #'Slovim-Core-Serialization'
}

{ #category : #converting }
SLVMSerializationGraphObjectProxy >> asSLVMMessagePackSerializableObject [
	^ self
]

{ #category : #accessing }
SLVMSerializationGraphObjectProxy >> earlyFields [
	^ earlyFields
]

{ #category : #accessing }
SLVMSerializationGraphObjectProxy >> earlyFields: anObject [
	earlyFields := anObject
]

{ #category : #accessing }
SLVMSerializationGraphObjectProxy >> fields [
	^ fields
]

{ #category : #accessing }
SLVMSerializationGraphObjectProxy >> fields: anObject [
	fields := anObject
]

{ #category : #accessing }
SLVMSerializationGraphObjectProxy >> id [
	^ id
]

{ #category : #accessing }
SLVMSerializationGraphObjectProxy >> id: anObject [
	id := anObject
]

{ #category : #accessing }
SLVMSerializationGraphObjectProxy >> object [
	^ object
]

{ #category : #accessing }
SLVMSerializationGraphObjectProxy >> object: anObject [
	object := anObject
]

{ #category : #printing }
SLVMSerializationGraphObjectProxy >> printOn: aStream [
	aStream nextPutAll: '<objectProxy type:'; print: type; nextPut: $>
]

{ #category : #converting }
SLVMSerializationGraphObjectProxy >> slvmMessagePackEncodeWith: encoder [
	encoder encodeSerializationGraphObject: self
]

{ #category : #accessing }
SLVMSerializationGraphObjectProxy >> type [
	^ type
]

{ #category : #accessing }
SLVMSerializationGraphObjectProxy >> type: anObject [
	type := anObject
]

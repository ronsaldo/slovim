"
I am an array that holds native data.
"
Class {
	#name : #SLVMNativeArray,
	#superclass : #ArrayedCollection,
	#instVars : [
		'type',
		'size',
		'data'
	],
	#category : #'Slovim-Runtime-Collections'
}

{ #category : #'instance creation' }
SLVMNativeArray class >> for: type new: size [
	^ self basicNew initFor: type size: size
]

{ #category : #'instance creation' }
SLVMNativeArray class >> new [
	self error: 'A type is required'
]

{ #category : #'instance creation' }
SLVMNativeArray class >> new: aSize [
	self error: 'A type is required'
]

{ #category : #'as yet unclassified' }
SLVMNativeArray >> _slvm_storeArrayValueInto: target type: arrayType [
	target _slvm_storeBytes: data count: arrayType size
]

{ #category : #converting }
SLVMNativeArray >> asByteArray [
	^ data
]

{ #category : #accessing }
SLVMNativeArray >> at: index [
	(index < 1 or: [ index > size ]) ifTrue: [ self errorSubscriptBounds: index ].
	^ self uncheckedAt: index
]

{ #category : #accessing }
SLVMNativeArray >> at: index put: anElement [
	(index < 1 or: [ index > size ]) ifTrue: [ self errorSubscriptBounds: index ].
	^ self uncheckedAt: index put: anElement
]

{ #category : #private }
SLVMNativeArray >> computeElementOffset: index [
	^ (index - 1) * self elementSize.
]

{ #category : #accessing }
SLVMNativeArray >> elementSize [
	^ type size
]

{ #category : #accessing }
SLVMNativeArray >> elementType [
	^ type
]

{ #category : #private }
SLVMNativeArray >> initFor: newType size: newSize [
	type := newType asSLVMType.
	size := newSize.
	data := ByteArray new: self rawDataSize.
]

{ #category : #'type checking' }
SLVMNativeArray >> lowcodeCheckArrayArgument: expectedElementType elements: expectedNumberOfElements [
	(expectedElementType withoutAliases ~= type withoutAliases or: [ self size < expectedNumberOfElements ]) ifTrue: [
		super lowcodeCheckArrayArgument: expectedElementType elements: expectedNumberOfElements
 ]
]

{ #category : #'as yet unclassified' }
SLVMNativeArray >> postCopy [
	data := data copy.
]

{ #category : #accessing }
SLVMNativeArray >> rawData [
	^ data
]

{ #category : #accessing }
SLVMNativeArray >> rawDataSize [
	^ self elementSize * size
]

{ #category : #accessing }
SLVMNativeArray >> size [
	^ size
]

{ #category : #private }
SLVMNativeArray >> species [
	^ Array
]

{ #category : #accessing }
SLVMNativeArray >> uncheckedAt: index [
	^ type readFromPointer: (SLVMInternalObjectPointer object: data offset: (self computeElementOffset: index))
]

{ #category : #private }
SLVMNativeArray >> uncheckedAt: index put: anElement [
	type write: anElement intoPointer: (SLVMInternalObjectPointer object: data offset: (self computeElementOffset: index)).
	^ anElement
]

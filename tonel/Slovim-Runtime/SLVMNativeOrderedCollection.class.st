"
I am ordered collection that holds inline data.
"
Class {
	#name : #SLVMNativeOrderedCollection,
	#superclass : #SequenceableCollection,
	#instVars : [
		'type',
		'size',
		'data',
		'capacity'
	],
	#category : #'Slovim-Runtime-Collections'
}

{ #category : #'instance creation' }
SLVMNativeOrderedCollection class >> for: type [
	^ self new type: type asSLVMType
]

{ #category : #'instance creation' }
SLVMNativeOrderedCollection class >> for: type new: initialCapacity [
	^ self new type: type asSLVMType; capacity: initialCapacity; yourself
]

{ #category : #'as yet unclassified' }
SLVMNativeOrderedCollection >> _slvm_storeArrayValueInto: target type: arrayType [
	target _slvm_storeBytes: data count: arrayType size
]

{ #category : #adding }
SLVMNativeOrderedCollection >> add: newElement [
	^self addLast: newElement
]

{ #category : #adding }
SLVMNativeOrderedCollection >> addLast: newElement [
	size >= capacity ifTrue: [ self increaseCapacity ].
	self uncheckedAt: size + 1 put: newElement.
	size := size + 1.
	^ newElement
]

{ #category : #converting }
SLVMNativeOrderedCollection >> asByteArray [
	| result |
	size = 0 ifTrue: [ ^ ByteArray new ].
	result := ByteArray new: size * self elementSize.
	LibC memCopy: data to: result size: result size.
	^ result
]

{ #category : #accessing }
SLVMNativeOrderedCollection >> at: index [
	(index < 1 or: [ index > size ]) ifTrue: [ self errorSubscriptBounds: index ].
	^ self uncheckedAt: index
]

{ #category : #accessing }
SLVMNativeOrderedCollection >> at: index put: anElement [
	(index < 1 or: [ index > size ]) ifTrue: [ self errorSubscriptBounds: index ].
	^ self uncheckedAt: index put: anElement
]

{ #category : #accessing }
SLVMNativeOrderedCollection >> capacity [
	^ capacity
]

{ #category : #accessing }
SLVMNativeOrderedCollection >> capacity: newCapacity [
	| newData |
	newCapacity = 0 ifTrue: [
		capacity := 0.
		size := 0.
		data := nil.
	].

	newData := ByteArray new: newCapacity * self elementSize.
	(size min: capacity) > 0 ifTrue: [
		LibC memCopy: data to: newData size: (size min: capacity) * self elementSize
	].
	capacity := newCapacity.
	data := newData.
]

{ #category : #enumerating }
SLVMNativeOrderedCollection >> collect: aBlock type: newType [
	"Evaluate aBlock with each of my elements as the argument. Collect the 
	resulting values into a collection that is like me. Answer the new 
	collection. Override superclass in order to use addLast:, not at:put:."

	| newCollection |
	newCollection := self class for: newType new: self size.
	1 to: size do:
		[:index |
		newCollection addLast: (aBlock value: (self uncheckedAt: index))].
	^ newCollection
]

{ #category : #enumerating }
SLVMNativeOrderedCollection >> collectWithSameType: aBlock [ 
	^ self collect: aBlock type: type
]

{ #category : #private }
SLVMNativeOrderedCollection >> computeElementOffset: index [
	^ (index - 1) * self elementSize.
]

{ #category : #private }
SLVMNativeOrderedCollection >> computeElementPosition: index [
	^ (index - 1) * self elementSize + 1.
]

{ #category : #accessing }
SLVMNativeOrderedCollection >> elementSize [
	^ type size
]

{ #category : #accessing }
SLVMNativeOrderedCollection >> elementType [
	^ type
]

{ #category : #private }
SLVMNativeOrderedCollection >> increaseCapacity [
	| newCapacity |
	newCapacity := capacity * 2.
	newCapacity = 0 ifTrue: [ newCapacity := 8 ].
	self capacity: newCapacity.
]

{ #category : #initialization }
SLVMNativeOrderedCollection >> initialize [
	size := 0.
	capacity := 0.
]

{ #category : #copying }
SLVMNativeOrderedCollection >> postCopy [
	data := data copy.
]

{ #category : #accessing }
SLVMNativeOrderedCollection >> rawData [
	^ data
]

{ #category : #accessing }
SLVMNativeOrderedCollection >> rawDataSize [
	^ self elementSize * size
]

{ #category : #removing }
SLVMNativeOrderedCollection >> removeAll [
	size := 0.
]

{ #category : #accessing }
SLVMNativeOrderedCollection >> size [
	^ size
]

{ #category : #private }
SLVMNativeOrderedCollection >> species [
	^ Array
]

{ #category : #accessing }
SLVMNativeOrderedCollection >> type [
	^ type
]

{ #category : #accessing }
SLVMNativeOrderedCollection >> type: anObject [
	type := anObject
]

{ #category : #private }
SLVMNativeOrderedCollection >> uncheckedAt: index [
	^ type readFromPointer: (SLVMInternalObjectPointer object: data offset: (self computeElementOffset: index))
]

{ #category : #private }
SLVMNativeOrderedCollection >> uncheckedAt: index put: anElement [
	type write: anElement intoPointer: (SLVMInternalObjectPointer object: data offset: (self computeElementOffset: index)).
	^ anElement
]

{ #category : #'as yet unclassified' }
SLVMNativeOrderedCollection >> useDataFromByteArray: aByteArray [
	data := aByteArray.
	capacity := size := aByteArray size // self elementSize.
]

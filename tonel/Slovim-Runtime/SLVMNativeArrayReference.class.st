Class {
	#name : #SLVMNativeArrayReference,
	#superclass : #SLVMNativeArray,
	#instVars : [
		'offset'
	],
	#category : #'Slovim-Runtime-Collections'
}

{ #category : #'as yet unclassified' }
SLVMNativeArrayReference class >> for: type offset: offset size: size data: data [
	^ self basicNew initWithType: type offset: offset size: size data: data
]

{ #category : #private }
SLVMNativeArrayReference >> computeElementOffset: element [
	^ (super computeElementOffset: element) + offset
]

{ #category : #'as yet unclassified' }
SLVMNativeArrayReference >> initWithType: aType offset: anOffset size: aSize data: aData [
	type := aType asSLVMType.
	offset := anOffset.
	data := aData.
	size := aSize.

]

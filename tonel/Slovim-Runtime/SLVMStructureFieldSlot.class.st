Class {
	#name : #SLVMStructureFieldSlot,
	#superclass : #Slot,
	#instVars : [
		'offset',
		'type'
	],
	#category : #'Slovim-Runtime-Slots'
}

{ #category : #accessing }
SLVMStructureFieldSlot >> alignment [
	^ type alignment
]

{ #category : #accessing }
SLVMStructureFieldSlot >> fieldSize [
	^ type size
]

{ #category : #testing }
SLVMStructureFieldSlot >> isVirtual [
	^ true
]

{ #category : #accessing }
SLVMStructureFieldSlot >> offset [
	^ offset
]

{ #category : #accessing }
SLVMStructureFieldSlot >> offset: anObject [
	offset := anObject
]

{ #category : #'meta-object-protocol' }
SLVMStructureFieldSlot >> read: anObject [
	^ anObject asPointerToInternalObjectData perform: type selectorForLoadingFromPointer
]

{ #category : #accessing }
SLVMStructureFieldSlot >> type [
	^ type
]

{ #category : #accessing }
SLVMStructureFieldSlot >> type: anObject [
	type := anObject
]

{ #category : #writing }
SLVMStructureFieldSlot >> write: value to: anObject [
	^ anObject asPointerToInternalObjectData perform: type selectorForStoringIntoPointer with: value
]

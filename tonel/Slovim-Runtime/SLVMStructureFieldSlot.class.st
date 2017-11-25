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

{ #category : #printing }
SLVMStructureFieldSlot >> printOn: aStream [
	aStream 
		store: self name;
		nextPutAll: ' => (';
		nextPutAll: self class name;
		nextPutAll: ' typeNamed: ';
		nextPutAll: type name printString;
		nextPutAll: ')'
]

{ #category : #'meta-object-protocol' }
SLVMStructureFieldSlot >> read: anObject [
	^ type readFromPointer: (anObject asPointerToInternalObjectData _slvm_pointerAddOffset: offset)
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
	^ type write: value intoPointer: (anObject asPointerToInternalObjectData _slvm_pointerAddOffset: offset)
]

Class {
	#name : #SLVMInternalObjectPointer,
	#superclass : #Object,
	#instVars : [
		'object',
		'offset'
	],
	#category : #'Slovim-Runtime-ObjectAccessors'
}

{ #category : #accessing }
SLVMInternalObjectPointer class >> object: object [
	^ self new object: object; offset: 0
]

{ #category : #accessing }
SLVMInternalObjectPointer class >> object: object offset: offset [
	^ self new object: object; offset: offset
]

{ #category : #arithmetic }
SLVMInternalObjectPointer >> + extraOffset [
	^ self class object: object offset: offset + extraOffset
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> boolValue [
	^ (object basicAt: offset + 1) ~~ 0
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> boolValue: aBoolean [
	^ object basicAt: offset + 1 put: (aBoolean ifTrue: [1] ifFalse: [0])
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> float32Value [
	^ Float fromIEEE32Bit: self uint32Value
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> float32Value: aFloat [
	^ self uint32Value: aFloat asIEEE32BitWord
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> float64Value [
	^ Float fromIEEE64Bit: self uint64Value
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> float64Value: aValue [
	^ self uint64Value: ((aValue basicAt: 1) << 32) | (aValue basicAt: 2)
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> int16Value [
	| result |
	result := (object basicAt: offset + 1) |
		((object basicAt: offset + 2) << 8).
	^ (result & 16r7FFF) - (result & 16r8000)
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> int16Value: anInteger [
	object
		basicAt: offset + 1 put: anInteger & 16rff;
		basicAt: offset + 2 put: (anInteger >> 8) & 16rff
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> int32Value [
	| result |
	result := (object basicAt: offset + 1) |
		((object basicAt: offset + 2) << 8) |
		((object basicAt: offset + 3) << 16) |
		((object basicAt: offset + 4) << 24).
	^ (result & 16r7FFFFFFF) - (result & 16r80000000)
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> int32Value: anInteger [
	object
		basicAt: offset + 1 put: anInteger & 16rff;
		basicAt: offset + 2 put: (anInteger >> 8) & 16rff;
		basicAt: offset + 3 put: (anInteger >> 16) & 16rff;
		basicAt: offset + 4 put: (anInteger >> 24) & 16rff
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> int64Value [
	| result |
	result := (object basicAt: offset + 1) |
		((object basicAt: offset + 2) << 8) |
		((object basicAt: offset + 3) << 16) |
		((object basicAt: offset + 4) << 24) |
		((object basicAt: offset + 5) << 32) |
		((object basicAt: offset + 6) << 40) |
		((object basicAt: offset + 7) << 48) |
		((object basicAt: offset + 8) << 56).
	^ (result & 16r7FFFFFFFFFFFFFFF) - (result & 16r8000000000000000)
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> int64Value: anInteger [
	object
		basicAt: offset + 1 put: anInteger & 16rff;
		basicAt: offset + 2 put: (anInteger >> 8) & 16rff;
		basicAt: offset + 3 put: (anInteger >> 16) & 16rff;
		basicAt: offset + 4 put: (anInteger >> 24) & 16rff;
		basicAt: offset + 5 put: (anInteger >> 32) & 16rff;
		basicAt: offset + 6 put: (anInteger >> 40) & 16rff;
		basicAt: offset + 7 put: (anInteger >> 48) & 16rff;
		basicAt: offset + 8 put: (anInteger >> 56) & 16rff
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> int8Value [
	| result |
	result := (object basicAt: offset + 1).
	^ (result & 16r7F) - (result & 16r80)
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> int8Value: anInteger [
	object
		basicAt: offset + 1 put: anInteger & 16rff
]

{ #category : #accessing }
SLVMInternalObjectPointer >> object [
	^ object
]

{ #category : #accessing }
SLVMInternalObjectPointer >> object: anObject [
	object := anObject
]

{ #category : #accessing }
SLVMInternalObjectPointer >> offset [
	^ offset
]

{ #category : #accessing }
SLVMInternalObjectPointer >> offset: anObject [
	offset := anObject
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> uint16Value [
	^ (object basicAt: offset + 1) |
		((object basicAt: offset + 2) << 8)
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> uint16Value: anInteger [
	object
		basicAt: offset + 1 put: anInteger & 16rff;
		basicAt: offset + 2 put: (anInteger >> 8) & 16rff
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> uint32Value [
	^ (object basicAt: offset + 1) |
		((object basicAt: offset + 2) << 8) |
		((object basicAt: offset + 3) << 16) |
		((object basicAt: offset + 4) << 24)
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> uint32Value: anInteger [
	object
		basicAt: offset + 1 put: anInteger & 16rff;
		basicAt: offset + 2 put: (anInteger >> 8) & 16rff;
		basicAt: offset + 3 put: (anInteger >> 16) & 16rff;
		basicAt: offset + 4 put: (anInteger >> 24) & 16rff

]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> uint64Value [
	^ (object basicAt: offset + 1) |
		((object basicAt: offset + 2) << 8) |
		((object basicAt: offset + 3) << 16) |
		((object basicAt: offset + 4) << 24) |
		((object basicAt: offset + 5) << 32) |
		((object basicAt: offset + 6) << 40) |
		((object basicAt: offset + 7) << 48) |
		((object basicAt: offset + 8) << 56)
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> uint64Value: anInteger [
	object
		basicAt: offset + 1 put: anInteger & 16rff;
		basicAt: offset + 2 put: (anInteger >> 8) & 16rff;
		basicAt: offset + 3 put: (anInteger >> 16) & 16rff;
		basicAt: offset + 4 put: (anInteger >> 24) & 16rff;
		basicAt: offset + 5 put: (anInteger >> 32) & 16rff;
		basicAt: offset + 6 put: (anInteger >> 40) & 16rff;
		basicAt: offset + 7 put: (anInteger >> 48) & 16rff;
		basicAt: offset + 8 put: (anInteger >> 56) & 16rff
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> uint8Value [
	^ (object basicAt: offset + 1)
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> uint8Value: anInteger [
	object
		basicAt: offset + 1 put: anInteger & 16rff
]

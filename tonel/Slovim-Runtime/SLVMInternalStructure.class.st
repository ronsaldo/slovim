Class {
	#name : #SLVMInternalStructure,
	#superclass : #Object,
	#category : #'Slovim-Runtime-Slots'
}

{ #category : #'instance creation' }
SLVMInternalStructure class >> basicNew [
	^ self basicNew: 0
]

{ #category : #'instance creation' }
SLVMInternalStructure class >> basicNew: aVariableSize [
	^ super basicNew: self structureSize + aVariableSize
]

{ #category : #accessing }
SLVMInternalStructure class >> structureAlignment [
	^ layout structureAlignment
]

{ #category : #accessing }
SLVMInternalStructure class >> structureSize [
	^ layout structureSize
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_boolValue [
	^ (self basicAt: 1) ~~ 0
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_boolValue: aBoolean [
	^ self basicAt: 1 put: (aBoolean ifTrue: [1] ifFalse: [0])
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_float32Value [
	^ Float fromIEEE32Bit: self _slvm_uint32Value
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_float32Value: aFloat [
	^ self _slvm_uint32Value: aFloat asIEEE32BitWord
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_float64Value [
	^ Float fromIEEE64Bit: self _slvm_uint64Value
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_float64Value: aValue [
	^ self _slvm_uint64Value: ((aValue basicAt: 1) << 32) | (aValue basicAt: 2)
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int16Value [
	| result |
	result := (self basicAt: 1) |
		((self basicAt: 2) << 8).
	^ (result & 16r7FFF) - (result & 16r8000)
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int16Value: anInteger [
	self
		basicAt: 1 put: anInteger & 16rff;
		basicAt: 2 put: (anInteger >> 8) & 16rff
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int32Value [
	| result |
	result := (self basicAt: 1) |
		((self basicAt: 2) << 8) |
		((self basicAt: 3) << 16) |
		((self basicAt: 4) << 24).
	^ (result & 16r7FFFFFFF) - (result & 16r80000000)
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int32Value: anInteger [
	self
		basicAt: 1 put: anInteger & 16rff;
		basicAt: 2 put: (anInteger >> 8) & 16rff;
		basicAt: 3 put: (anInteger >> 16) & 16rff;
		basicAt: 4 put: (anInteger >> 24) & 16rff
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int64Value [
	| result |
	result := (self basicAt: 1) |
		((self basicAt: 2) << 8) |
		((self basicAt: 3) << 16) |
		((self basicAt: 4) << 24) |
		((self basicAt: 5) << 32) |
		((self basicAt: 6) << 40) |
		((self basicAt: 7) << 48) |
		((self basicAt: 8) << 56).
	^ (result & 16r7FFFFFFFFFFFFFFF) - (result & 16r8000000000000000)
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int64Value: anInteger [
	self
		basicAt: 1 put: anInteger & 16rff;
		basicAt: 2 put: (anInteger >> 8) & 16rff;
		basicAt: 3 put: (anInteger >> 16) & 16rff;
		basicAt: 4 put: (anInteger >> 24) & 16rff;
		basicAt: 5 put: (anInteger >> 32) & 16rff;
		basicAt: 6 put: (anInteger >> 40) & 16rff;
		basicAt: 7 put: (anInteger >> 48) & 16rff;
		basicAt: 8 put: (anInteger >> 56) & 16rff
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int8Value [
	| result |
	result := (self basicAt: 1).
	^ (result & 16r7F) - (result & 16r80)
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int8Value: anInteger [
	self
		basicAt: 1 put: anInteger & 16rff
]

{ #category : #'as yet unclassified' }
SLVMInternalStructure >> _slvm_loadStructureValue: internalStructureType [
	internalStructureType == self class ifTrue: [ ^ self ].
	self halt
]

{ #category : #arithmetic }
SLVMInternalStructure >> _slvm_pointerAddOffset: extraOffset [
	^ SLVMInternalObjectPointer new object: self; offset: extraOffset; yourself
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint16Value [
	^ (self basicAt: 1) |
		((self basicAt: 2) << 8)
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint16Value: anInteger [
	self
		basicAt: 1 put: anInteger & 16rff;
		basicAt: 2 put: (anInteger >> 8) & 16rff
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint32Value [
	^ (self basicAt: 1) |
		((self basicAt: 2) << 8) |
		((self basicAt: 3) << 16) |
		((self basicAt: 4) << 24)
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint32Value: anInteger [
	self
		basicAt: 1 put: anInteger & 16rff;
		basicAt: 2 put: (anInteger >> 8) & 16rff;
		basicAt: 3 put: (anInteger >> 16) & 16rff;
		basicAt: 4 put: (anInteger >> 24) & 16rff

]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint64Value [
	^ (self basicAt: 1) |
		((self basicAt: 2) << 8) |
		((self basicAt: 3) << 16) |
		((self basicAt: 4) << 24) |
		((self basicAt: 5) << 32) |
		((self basicAt: 6) << 40) |
		((self basicAt: 7) << 48) |
		((self basicAt: 8) << 56)
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint64Value: anInteger [
	self
		basicAt: 1 put: anInteger & 16rff;
		basicAt: 2 put: (anInteger >> 8) & 16rff;
		basicAt: 3 put: (anInteger >> 16) & 16rff;
		basicAt: 4 put: (anInteger >> 24) & 16rff;
		basicAt: 5 put: (anInteger >> 32) & 16rff;
		basicAt: 6 put: (anInteger >> 40) & 16rff;
		basicAt: 7 put: (anInteger >> 48) & 16rff;
		basicAt: 8 put: (anInteger >> 56) & 16rff
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint8Value [
	^ (self basicAt: 1)
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint8Value: anInteger [
	self
		basicAt: 1 put: anInteger & 16rff
]

{ #category : #accessing }
SLVMInternalStructure >> byteAt: index [
	<primitive: 60>
	^self basicAt: index
]

{ #category : #accessing }
SLVMInternalStructure >> byteAt: index put: value [
	<primitive: 61>
	^self at: index put: value
]

{ #category : #'gt-inspector' }
SLVMInternalStructure >> gtInspectorVariableNodesIn: aCollection [
	"Only show the slots. Do not show the raw data."
	
	aCollection
		addAll: ((self class allSlots collect: [ :slot | 
			GTInspectorSlotNode hostObject: self slot: slot ]))
]

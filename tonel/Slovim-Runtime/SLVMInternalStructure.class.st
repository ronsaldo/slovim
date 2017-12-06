Class {
	#name : #SLVMInternalStructure,
	#superclass : #Object,
	#traits : 'TSLVMInternalStructureAccessingPrimitives',
	#classTraits : 'TSLVMInternalStructureAccessingPrimitives classTrait',
	#classInstVars : [
		'_slvm_type'
	],
	#category : #'Slovim-Runtime-Slots'
}

{ #category : #accessing }
SLVMInternalStructure class >> _slvm_type [
	^ _slvm_type
]

{ #category : #accessing }
SLVMInternalStructure class >> _slvm_type: aType [
	_slvm_type :=  aType
]

{ #category : #accessing }
SLVMInternalStructure class >> asSLVMType [
	^ _slvm_type
]

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
SLVMInternalStructure >> _slvm_boolValueAt: offset [
	"Booleans are just integers in C word"
	^ (self _slvm_integerAt: offset + 1 size: 1 signed: false) == true
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_boolValueAt: offset put: value [
	"Booleans are just integers in C word"
	^ self integerAt: offset + 1 put: (value ifTrue:[1] ifFalse:[0]) size: 1 signed: false
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_float32ValueAt: extraOffset [
	^ self _slvm_primitiveFloatAt: extraOffset + 1
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_float32ValueAt: extraOffset put: value [
	^ self _slvm_primitiveFloatAt: extraOffset + 1 put: value
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_float64ValueAt: extraOffset [
	^ self _slvm_primitiveDoubleAt: extraOffset + 1
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_float64ValueAt: extraOffset put: value [
	^ self _slvm_primitiveDoubleAt: extraOffset + 1 put: value
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int16ValueAt: extraOffset [
	"Return a 16-bit signed integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 size: 2 signed: true
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int16ValueAt: extraOffset put: value [
	"Return a 16-bit signed integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 put: value size: 2 signed: true
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int32ValueAt: extraOffset [
	"Return a 32-bit signed integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 size: 4 signed: true
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int32ValueAt: extraOffset put: value [
	"Return a 32-bit signed integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 put: value size: 4 signed: true
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int64ValueAt: extraOffset [
	"Return a 16bit signed integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 size: 8 signed: true
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int64ValueAt: extraOffset put: value [
	"Return a 64-bit signed integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 put: value size: 8 signed: true
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int8ValueAt: extraOffset [
	"Return a 8-bit signed integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 size: 1 signed: true
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_int8ValueAt: extraOffset put: value [
	"Return a 8-bit signed integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 put: value size: 1 signed: true
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_integerAt: byteOffset put: value size: nBytes signed: aBoolean [
	"Primitive. Store the given value as integer of nBytes size
	in the receiver. Fail if the value is out of range.
	Note: This primitive will access memory in the outer space if
	invoked from ExternalAddress."
	<primitive: 'primitiveFFIIntegerAtPut' module:'SqueakFFIPrims'>
	^self primitiveFailed
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_integerAt: byteOffset size: nBytes signed: aBoolean [
	"We are just reusing the FFI primitives here."
	
	"Primitive. Return an integer of nBytes size from the receiver.
	Note: This primitive will access memory in the outer space if
	invoked from ExternalAddress."
	<primitive: 'primitiveFFIIntegerAt' module:'SqueakFFIPrims'>
	^self primitiveFailed
]

{ #category : #arithmetic }
SLVMInternalStructure >> _slvm_pointerAddOffset: extraOffset [
	^ SLVMInternalObjectPointer new object: self; offset: extraOffset; yourself
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_primitiveDoubleAt: byteOffset [
	<primitive:'primitiveFFIDoubleAt' module:'SqueakFFIPrims'>
	^self primitiveFailed
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_primitiveDoubleAt: byteOffset put: value [
	<primitive:'primitiveFFIDoubleAtPut' module:'SqueakFFIPrims'>
	^self primitiveFailed
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_primitiveFloatAt: byteOffset [
	<primitive:'primitiveFFIFloatAt' module:'SqueakFFIPrims'>
	^self primitiveFailed
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_primitiveFloatAt: byteOffset put: value [
	<primitive:'primitiveFFIFloatAtPut' module:'SqueakFFIPrims'>
	^self primitiveFailed
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint16ValueAt: extraOffset [
	"Return a 16-bit unsigned integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 size: 2 signed: false
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint16ValueAt: extraOffset put: value [
	"Return a 16-bit signed integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 put: value size: 2 signed: false
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint32ValueAt: extraOffset [
	"Return a 32-bit unsigned integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 size: 4 signed: false
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint32ValueAt: extraOffset put: value [
	"Return a 32-bit signed integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 put: value size: 4 signed: false
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint64ValueAt: extraOffset [
	"Return a 64-bit unsigned integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 size: 8 signed: false
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint64ValueAt: extraOffset put: value [
	"Return a 64-bit signed integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 put: value size: 8 signed: false
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint8ValueAt: extraOffset [
	"Return a 8-bit unsigned integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 size: 1 signed: false
]

{ #category : #'value accessors' }
SLVMInternalStructure >> _slvm_uint8ValueAt: extraOffset put: value [
	"Return a 8-bit signed integer starting at the given byte offset"
	^self _slvm_integerAt: extraOffset + 1 put: value size: 1 signed: false
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

{ #category : #'memory access' }
SLVMInternalStructure >> readBytesFrom: aByteArray [
	self readBytesFrom: aByteArray position: 1
]

{ #category : #'memory access' }
SLVMInternalStructure >> readBytesFrom: aByteArray position: byteArrayPosition [
	| layoutSize |
	layoutSize := self class structureSize.
	1 to: layoutSize do: [ :i |
		self basicAt: i put: (aByteArray byteAt: byteArrayPosition + i - 1)
	]
]

{ #category : #'memory access' }
SLVMInternalStructure >> readBytesFrom: aByteArray size: readSize position: byteArrayPosition [
	1 to: readSize do: [ :i |
		self basicAt: i put: (aByteArray byteAt: byteArrayPosition + i - 1)
	]
]

{ #category : #'memory access' }
SLVMInternalStructure >> replaceFrom: start to: stop with: replacement startingAt: repStart [
	"This method is required by Fuel."
	^ self _slvm_replaceBytesFrom: start to: stop with: replacement startingAt: repStart

]

{ #category : #'memory access' }
SLVMInternalStructure >> storeBytesIn: aByteArray [
	self storeBytesIn: aByteArray position: 1
]

{ #category : #'memory access' }
SLVMInternalStructure >> storeBytesIn: aByteArray position: byteArrayPosition [
	| layoutSize |
	layoutSize := self class structureSize.
	1 to: layoutSize do: [ :i |
		aByteArray byteAt: byteArrayPosition + i - 1 put: (self basicAt: i)
	]
]

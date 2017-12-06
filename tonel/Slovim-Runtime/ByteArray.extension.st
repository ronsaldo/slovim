Extension { #name : #ByteArray }

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_boolValueAt: offset [
	^ self booleanAt: offset + 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_boolValueAt: offset put: newValue [
	^ self booleanAt: offset + 1 put: newValue
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_copySource [
	^ self
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_copySourceOffset [
	^ 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_float32ValueAt: offset [
	^ self floatAt: offset + 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_float32ValueAt: offset put: newValue [
	^ self floatAt: offset + 1 put: newValue
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_float64ValueAt: offset [
	^ self doubleAt: offset + 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_float64ValueAt: offset put: newValue [
	^ self doubleAt: offset + 1 put: newValue
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int16ValueAt: offset [
	^ self signedShortAt: offset + 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int16ValueAt: offset put: newValue [
	^ self signedShortAt: offset + 1 put: newValue
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int32ValueAt: offset [
	^ self signedLongAt: offset + 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int32ValueAt: offset put: newValue [
	^ self signedLongAt: offset + 1 put: newValue
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int64ValueAt: offset [
	^ self signedLongLongAt: offset + 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int64ValueAt: offset put: newValue [
	^ self signedLongLongAt: offset + 1 put: newValue
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int8ValueAt: offset [
	^ self signedByteAt: offset + 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int8ValueAt: offset put: newValue [
	^ self signedByteAt: offset + 1 put: newValue
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_replaceBytesFrom: start to: stop with: replacement startingAt: repStart [
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."
	<primitive: 105>
	self primitiveFailed
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint16ValueAt: offset [
	^ self unsignedShortAt: offset + 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint16ValueAt: offset put: newValue [
	^ self unsignedShortAt: offset + 1 put: newValue
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint32ValueAt: offset [
	^ self unsignedLongAt: offset + 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint32ValueAt: offset put: newValue [
	^ self unsignedLongAt: offset + 1 put: newValue
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint64ValueAt: offset [
	^ self unsignedLongLongAt: offset + 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint64ValueAt: offset put: newValue [
	^ self unsignedLongLongAt: offset + 1 put: newValue
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint8ValueAt: offset [
	^ self unsignedByteAt: offset + 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint8ValueAt: offset put: newValue [
	^ self unsignedByteAt: offset + 1 put: newValue
]

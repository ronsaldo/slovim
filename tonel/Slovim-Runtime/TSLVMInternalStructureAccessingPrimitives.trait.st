Trait {
	#name : #TSLVMInternalStructureAccessingPrimitives,
	#category : #'Slovim-Runtime-ObjectAccessors'
}

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_boolValue [
	^ self _slvm_boolValueAt: 0
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_boolValue: newValue [
	^ self _slvm_boolValueAt: 0 put: newValue
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_boolValueAt: extraOffset [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_boolValueAt: extraOffset put: value [
	self explicitRequirement
]

{ #category : #'aggregate accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_copySource [
	^ self
]

{ #category : #'aggregate accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_copySourceOffset [
	^ 1
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_float32Value [
	^ self _slvm_float32ValueAt: 0
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_float32Value: newValue [
	^ self _slvm_float32ValueAt: 0 put: newValue
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_float32ValueAt: extraOffset [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_float32ValueAt: extraOffset put: value [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_float64Value [
	^ self _slvm_float64ValueAt: 0
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_float64Value: newValue [
	^ self _slvm_float64ValueAt: 0 put: newValue
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_float64ValueAt: extraOffset [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_float64ValueAt: extraOffset put: value [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int16Value [
	^ self _slvm_int16ValueAt: 0
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int16Value: newValue [
	^ self _slvm_int16ValueAt: 0 put: newValue
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int16ValueAt: extraOffset [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int16ValueAt: extraOffset put: value [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int32Value [
	^ self _slvm_int32ValueAt: 0
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int32Value: newValue [
	^ self _slvm_int32ValueAt: 0 put: newValue
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int32ValueAt: extraOffset [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int32ValueAt: extraOffset put: value [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int64Value [
	^ self _slvm_int64ValueAt: 0
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int64Value: newValue [
	^ self _slvm_int64ValueAt: 0 put: newValue
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int64ValueAt: extraOffset [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int64ValueAt: extraOffset put: value [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int8Value [
	^ self _slvm_int8ValueAt: 0
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int8Value: newValue [
	^ self _slvm_int8ValueAt: 0 put: newValue
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int8ValueAt: extraOffset [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_int8ValueAt: extraOffset put: value [
	self explicitRequirement
]

{ #category : #'aggregate accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_loadBytesInto: target count: aCount [
	target _slvm_replaceBytesFrom: 1 to: aCount with: self _slvm_copySource startingAt: self _slvm_copySourceOffset
]

{ #category : #'aggregate accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_loadStructureValue: internalStructureType [
	| result |
	self class == internalStructureType ifTrue: [ ^ self copy ].

	result := internalStructureType new.
	result _slvm_replaceBytesFrom: 1 to: internalStructureType structureSize with: self startingAt: 1.
	^ result
]

{ #category : #'aggregate accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_replaceBytesFrom: start to: stop with: replacement startingAt: repStart [
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."
	<primitive: 105>
	self primitiveFailed
]

{ #category : #'aggregate accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_storeArrayValue: value type: arrayType [
	self _slvm_replaceBytesFrom: 1 to: arrayType size with: value _slvm_copySource startingAt: value _slvm_copySourceOffset
]

{ #category : #'aggregate accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_storeBytes: bytes count: aCount [
	1 to: aCount do: [ :i |
		self
			byteAt: i put: (bytes at: i)
	].

]

{ #category : #'aggregate accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_storeStructureValue: value behavior: behavior [
	self _slvm_replaceBytesFrom: 1 to: behavior structureSize with: value _slvm_copySource startingAt: value _slvm_copySourceOffset
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint16Value [
	^ self _slvm_uint16ValueAt: 0
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint16Value: newValue [
	^ self _slvm_uint16ValueAt: 0 put: newValue
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint16ValueAt: extraOffset [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint16ValueAt: extraOffset put: value [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint32Value [
	^ self _slvm_uint32ValueAt: 0
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint32Value: newValue [
	^ self _slvm_uint32ValueAt: 0 put: newValue
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint32ValueAt: extraOffset [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint32ValueAt: extraOffset put: value [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint64Value [
	^ self _slvm_uint64ValueAt: 0
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint64Value: newValue [
	^ self _slvm_uint64ValueAt: 0 put: newValue
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint64ValueAt: extraOffset [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint64ValueAt: extraOffset put: value [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint8Value [
	^ self _slvm_uint8ValueAt: 0
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint8Value: newValue [
	^ self _slvm_uint8ValueAt: 0 put: newValue
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint8ValueAt: extraOffset [
	self explicitRequirement
]

{ #category : #'value accessors' }
TSLVMInternalStructureAccessingPrimitives >> _slvm_uint8ValueAt: extraOffset put: value [
	self explicitRequirement
]

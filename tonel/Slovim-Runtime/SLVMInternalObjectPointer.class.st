Class {
	#name : #SLVMInternalObjectPointer,
	#superclass : #Object,
	#traits : 'TSLVMInternalStructureAccessingPrimitives',
	#classTraits : 'TSLVMInternalStructureAccessingPrimitives classTrait',
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

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_boolValueAt: extraOffset [
	^ object _slvm_boolValueAt: offset + extraOffset
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_boolValueAt: extraOffset put: value [
	^ object _slvm_boolValueAt: offset + extraOffset put: value
]

{ #category : #'aggregate accessors' }
SLVMInternalObjectPointer >> _slvm_copySource [
	^ object
]

{ #category : #'aggregate accessors' }
SLVMInternalObjectPointer >> _slvm_copySourceOffset [
	^ 1 + offset
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_float32ValueAt: extraOffset [
	^ object _slvm_float32ValueAt: offset + extraOffset
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_float32ValueAt: extraOffset put: value [
	^ object _slvm_float32ValueAt: offset + extraOffset put: value
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_float64ValueAt: extraOffset [
	^ object _slvm_float64ValueAt: offset + extraOffset
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_float64ValueAt: extraOffset put: value [
	^ object _slvm_float64ValueAt: offset + extraOffset put: value
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_int16ValueAt: extraOffset [
	^ object _slvm_int16ValueAt: offset + extraOffset
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_int16ValueAt: extraOffset put: value [
	^ object _slvm_int16ValueAt: offset + extraOffset put: value
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_int32ValueAt: extraOffset [
	^ object _slvm_int32ValueAt: offset + extraOffset
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_int32ValueAt: extraOffset put: value [
	^ object _slvm_int32ValueAt: offset + extraOffset put: value
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_int64ValueAt: extraOffset [
	^ object _slvm_int64ValueAt: offset + extraOffset
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_int64ValueAt: extraOffset put: value [
	^ object _slvm_int64ValueAt: offset + extraOffset put: value
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_int8ValueAt: extraOffset [
	^ object _slvm_int8ValueAt: offset + extraOffset
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_int8ValueAt: extraOffset put: value [
	^ object _slvm_int8ValueAt: offset + extraOffset put: value
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_loadStructureValue: internalStructureType [
	| result |
	(offset = 0 and: [object class == internalStructureType]) ifTrue:[
		^ object _slvm_loadStructureValue: internalStructureType
	].

	result := internalStructureType new.
	result _slvm_replaceBytesFrom: 1 to: internalStructureType structureSize with: object startingAt: offset + 1.
	^ result
]

{ #category : #arithmetic }
SLVMInternalObjectPointer >> _slvm_pointerAddOffset: extraOffset [
	^ self class object: object offset: offset + extraOffset
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_replaceBytesFrom: start to: stop with: replacement startingAt: repStart [
	^ object _slvm_replaceBytesFrom: offset + start to: offset + stop with: replacement startingAt: repStart
]

{ #category : #'aggregate accessors' }
SLVMInternalObjectPointer >> _slvm_storeArrayValueInto: target type: arrayType [
	target _slvm_storeArrayValue: self type: arrayType
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_uint16ValueAt: extraOffset [
	^ object _slvm_uint16ValueAt: offset + extraOffset
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_uint16ValueAt: extraOffset put: value [
	^ object _slvm_uint16ValueAt: offset + extraOffset put: value
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_uint32ValueAt: extraOffset [
	^ object _slvm_uint32ValueAt: offset + extraOffset
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_uint32ValueAt: extraOffset put: value [
	^ object _slvm_uint32ValueAt: offset + extraOffset put: value
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_uint64ValueAt: extraOffset [
	^ object _slvm_uint64ValueAt: offset + extraOffset
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_uint64ValueAt: extraOffset put: value [
	^ object _slvm_uint64ValueAt: offset + extraOffset put: value
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_uint8ValueAt: extraOffset [
	^ object _slvm_uint8ValueAt: offset + extraOffset
]

{ #category : #'value accessors' }
SLVMInternalObjectPointer >> _slvm_uint8ValueAt: extraOffset put: value [
	^ object _slvm_uint8ValueAt: offset + extraOffset put: value
]

{ #category : #accessing }
SLVMInternalObjectPointer >> byteAt: index [
	^ object byteAt: offset + index
]

{ #category : #accessing }
SLVMInternalObjectPointer >> byteAt: index put: value [
	^ object byteAt: offset + index put: value
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

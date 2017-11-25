Extension { #name : #Object }

{ #category : #'*Slovim-Runtime' }
Object >> _slvm_boolValueInto: pointer [
	^ pointer _slvm_boolValue: self
]

{ #category : #'*Slovim-Runtime' }
Object >> _slvm_float32ValueInto: pointer [
	^ pointer _slvm_float32Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> _slvm_float64ValueInto: pointer [
	^ pointer _slvm_float64Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> _slvm_int16ValueInto: pointer [
	^ pointer _slvm_int16Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> _slvm_int32ValueInto: pointer [
	^ pointer _slvm_int32Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> _slvm_int64ValueInto: pointer [
	^ pointer _slvm_int64Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> _slvm_int8ValueInto: pointer [
	^ pointer _slvm_int8Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> _slvm_storeStructureValueInto: pointer behavior: behavior [
	^ pointer _slvm_storeStructureValue: self behavior: behavior
]

{ #category : #'*Slovim-Runtime' }
Object >> _slvm_uint16ValueInto: pointer [
	^ pointer _slvm_uint16Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> _slvm_uint32ValueInto: pointer [
	^ pointer _slvm_uint32Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> _slvm_uint64ValueInto: pointer [
	^ pointer _slvm_uint64Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> _slvm_uint8ValueInto: pointer [
	^ pointer _slvm_uint8Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> asPointerToInternalObjectData [
	^ SLVMInternalObjectPointer object: self
]

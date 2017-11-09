Extension { #name : #Object }

{ #category : #'*Slovim-Runtime' }
Object >> asPointerToInternalObjectData [
	^ SLVMInternalObjectPointer object: self
]

{ #category : #'*Slovim-Runtime' }
Object >> boolValueInto: pointer [
	^ pointer boolValue: self
]

{ #category : #'*Slovim-Runtime' }
Object >> float32ValueInto: pointer [
	^ pointer float32Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> float64ValueInto: pointer [
	^ pointer float64Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> int16ValueInto: pointer [
	^ pointer int16Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> int32ValueInto: pointer [
	^ pointer int32Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> int64ValueInto: pointer [
	^ pointer int64Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> int8ValueInto: pointer [
	^ pointer int8Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> uint16ValueInto: pointer [
	^ pointer uint16Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> uint32ValueInto: pointer [
	^ pointer uint32Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> uint64ValueInto: pointer [
	^ pointer uint64Value: self
]

{ #category : #'*Slovim-Runtime' }
Object >> uint8ValueInto: pointer [
	^ pointer uint8Value: self
]

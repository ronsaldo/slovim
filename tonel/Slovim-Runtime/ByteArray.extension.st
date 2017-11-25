Extension { #name : #ByteArray }

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_boolValue [
	^ (self byteAt: 1) ~~ 0
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_boolValue: aValue [
	^ self byteAt: 1 put: (aValue ifTrue: [ 1 ] ifFalse: [0])
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_float32Value [
	^ self floatAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_float32Value: aFloat [
	^ self floatAt: 1 put: aFloat
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_float64Value [
	^ self doubleAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_float64Value: aFloat [
	^ self doubleAt: 1 put: aFloat
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int16Value [
	^ self signedShortAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int16Value: anInteger [
	^ self signedShortAt: 1 put: anInteger
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int32Value [
	^ self signedLongAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int32Value: anInteger [
	^ self signedLongAt: 1 put: anInteger
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int64Value [
	^ self signedLongLongAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int64Value: anInteger [
	^ self signedLongLongAt: 1 put: anInteger
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int8Value [
	^ self signedByteAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_int8Value: anInteger [
	^ self signedByteAt: 1 put: anInteger
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint16Value [
	^ self unsignedShortAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint16Value: anInteger [
	^ self unsignedShortAt: 1 put: anInteger
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint32Value [
	^ self unsignedLongAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint32Value: anInteger [
	^ self unsignedLongAt: 1 put: anInteger
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint64Value [
	^ self unsignedLongLongAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint64Value: anInteger [
	^ self unsignedLongLongAt: 1 put: anInteger
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint8Value [
	^ self unsignedByteAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> _slvm_uint8Value: anInteger [
	^ self unsignedByteAt: 1 put: anInteger
]

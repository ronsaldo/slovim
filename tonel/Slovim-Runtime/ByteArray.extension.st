Extension { #name : #ByteArray }

{ #category : #'*Slovim-Runtime' }
ByteArray >> boolValue [
	^ (self byteAt: 1) ~~ 0
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> boolValue: aValue [
	^ self byteAt: 1 put: (aValue ifTrue: [ 1 ] ifFalse: [0])
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> float32Value [
	^ self floatAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> float32Value: aFloat [
	^ self floatAt: 1 put: aFloat
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> float64Value [
	^ self doubleAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> float64Value: aFloat [
	^ self doubleAt: 1 put: aFloat
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> int16Value [
	^ self signedShortAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> int16Value: anInteger [
	^ self signedShortAt: 1 put: anInteger
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> int32Value [
	^ self signedLongAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> int32Value: anInteger [
	^ self signedLongAt: 1 put: anInteger
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> int64Value [
	^ self signedLongLongAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> int64Value: anInteger [
	^ self signedLongLongAt: 1 put: anInteger
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> int8Value [
	^ self signedByteAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> int8Value: anInteger [
	^ self signedByteAt: 1 put: anInteger
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> uint16Value [
	^ self unsignedShortAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> uint16Value: anInteger [
	^ self unsignedShortAt: 1 put: anInteger
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> uint32Value [
	^ self unsignedLongAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> uint32Value: anInteger [
	^ self unsignedLongAt: 1 put: anInteger
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> uint64Value [
	^ self unsignedLongLongAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> uint64Value: anInteger [
	^ self unsignedLongLongAt: 1 put: anInteger
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> uint8Value [
	^ self unsignedByteAt: 1
]

{ #category : #'*Slovim-Runtime' }
ByteArray >> uint8Value: anInteger [
	^ self unsignedByteAt: 1 put: anInteger
]

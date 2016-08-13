Class {
	#name : #SLVMLirMachineCodeWriter,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #'as yet unclassified' }
SLVMLirMachineCodeWriter class >> do: aBlock [
	^ self new do: aBlock
]

{ #category : #enumerating }
SLVMLirMachineCodeWriter >> do: aBlock [
	^ ByteArray streamContents: [ :out |
		stream := out.
		aBlock value: self
	]
	
]

{ #category : #accessing }
SLVMLirMachineCodeWriter >> position [
	^ stream position
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> put: value [
	stream nextPut: value
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putInt16: value [
	self
		put: (value bitAnd: 16rff);
		put: ((value >> 8) bitAnd: 16rff)
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putInt32: value [
	self
		put: (value bitAnd: 16rff);
		put: ((value >> 8) bitAnd: 16rff);
		put: ((value >> 16) bitAnd: 16rff);
		put: ((value >> 24) bitAnd: 16rff).
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putInt8: value [
	self put: value
]

{ #category : #accessing }
SLVMLirMachineCodeWriter >> stream [
	^ stream
]

{ #category : #accessing }
SLVMLirMachineCodeWriter >> stream: anObject [
	stream := anObject
]

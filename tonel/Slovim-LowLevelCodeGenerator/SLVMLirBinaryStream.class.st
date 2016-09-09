Class {
	#name : #SLVMLirBinaryStream,
	#superclass : #ReadWriteStream,
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #'as yet unclassified' }
SLVMLirBinaryStream >> nextPutInt16: value [
	self
		nextPut: (value bitAnd: 16rff);
		nextPut: ((value >> 8) bitAnd: 16rff)
]

{ #category : #'as yet unclassified' }
SLVMLirBinaryStream >> nextPutInt32: value [
	self
		nextPut: (value bitAnd: 16rff);
		nextPut: ((value >> 8) bitAnd: 16rff);
		nextPut: ((value >> 16) bitAnd: 16rff);
		nextPut: ((value >> 24) bitAnd: 16rff).
]

{ #category : #'as yet unclassified' }
SLVMLirBinaryStream >> nextPutInt64: value [
	self
		nextPut: (value bitAnd: 16rff);
		nextPut: ((value >> 8) bitAnd: 16rff);
		nextPut: ((value >> 16) bitAnd: 16rff);
		nextPut: ((value >> 24) bitAnd: 16rff);
		nextPut: ((value >> 32) bitAnd: 16rff);
		nextPut: ((value >> 40) bitAnd: 16rff);
		nextPut: ((value >> 48) bitAnd: 16rff);
		nextPut: ((value >> 56) bitAnd: 16rff).
]

{ #category : #'as yet unclassified' }
SLVMLirBinaryStream >> nextPutInt8: value [
	self nextPut: (value bitAnd: 16rff)
]

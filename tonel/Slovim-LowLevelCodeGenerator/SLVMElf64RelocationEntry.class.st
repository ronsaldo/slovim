Class {
	#name : #SLVMElf64RelocationEntry,
	#superclass : #SLVMElf32RelocationEntry,
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #'as yet unclassified' }
SLVMElf64RelocationEntry class >> entrySize [
	^ 16
]

{ #category : #'as yet unclassified' }
SLVMElf64RelocationEntry >> symbol [
	^ info >> 32
]

{ #category : #'as yet unclassified' }
SLVMElf64RelocationEntry >> symbol: symbol type: type [
	info := (symbol << 32) | type
]

{ #category : #'as yet unclassified' }
SLVMElf64RelocationEntry >> type [
	^ info bitAnd: 16rffffffff
]

{ #category : #'as yet unclassified' }
SLVMElf64RelocationEntry >> writeOn: aStream [
	aStream
		nextPutInt64: offset;
		nextPutInt64: info
]

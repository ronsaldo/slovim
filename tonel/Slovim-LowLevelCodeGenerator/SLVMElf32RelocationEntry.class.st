Class {
	#name : #SLVMElf32RelocationEntry,
	#superclass : #Object,
	#instVars : [
		'offset',
		'info'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #'as yet unclassified' }
SLVMElf32RelocationEntry class >> entrySize [
	^ 8
]

{ #category : #accessing }
SLVMElf32RelocationEntry >> info [
	^ info
]

{ #category : #accessing }
SLVMElf32RelocationEntry >> info: anObject [
	info := anObject
]

{ #category : #accessing }
SLVMElf32RelocationEntry >> offset [
	^ offset
]

{ #category : #accessing }
SLVMElf32RelocationEntry >> offset: anObject [
	offset := anObject
]

{ #category : #'as yet unclassified' }
SLVMElf32RelocationEntry >> symbol [
	^ info >> 8
]

{ #category : #'as yet unclassified' }
SLVMElf32RelocationEntry >> symbol: symbol type: type [
	info := (symbol << 8) | type
]

{ #category : #'as yet unclassified' }
SLVMElf32RelocationEntry >> type [
	^ info bitAnd: 16rff
]

{ #category : #'as yet unclassified' }
SLVMElf32RelocationEntry >> writeOn: aStream [
	aStream
		nextPutInt32: offset;
		nextPutInt32: info
]

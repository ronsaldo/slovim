Class {
	#name : #SLVMElf32SymbolTableEntry,
	#superclass : #Object,
	#instVars : [
		'name',
		'value',
		'size',
		'info',
		'other',
		'sectionHeaderIndex'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #'as yet unclassified' }
SLVMElf32SymbolTableEntry class >> entrySize [
	^ 16
]

{ #category : #accessing }
SLVMElf32SymbolTableEntry >> info [
	^ info
]

{ #category : #accessing }
SLVMElf32SymbolTableEntry >> info: anObject [
	info := anObject
]

{ #category : #initialization }
SLVMElf32SymbolTableEntry >> initialize [
	super initialize.
	name := 0.
	value := 0.
	size := 0.
	info := 0.
	other := 0.
	sectionHeaderIndex := 0.
]

{ #category : #accessing }
SLVMElf32SymbolTableEntry >> name [
	^ name
]

{ #category : #accessing }
SLVMElf32SymbolTableEntry >> name: anObject [
	name := anObject
]

{ #category : #accessing }
SLVMElf32SymbolTableEntry >> other [
	^ other
]

{ #category : #accessing }
SLVMElf32SymbolTableEntry >> other: anObject [
	other := anObject
]

{ #category : #accessing }
SLVMElf32SymbolTableEntry >> sectionHeaderIndex [
	^ sectionHeaderIndex
]

{ #category : #accessing }
SLVMElf32SymbolTableEntry >> sectionHeaderIndex: anObject [
	sectionHeaderIndex := anObject
]

{ #category : #accessing }
SLVMElf32SymbolTableEntry >> size [
	^ size
]

{ #category : #accessing }
SLVMElf32SymbolTableEntry >> size: anObject [
	size := anObject
]

{ #category : #accessing }
SLVMElf32SymbolTableEntry >> value [
	^ value
]

{ #category : #accessing }
SLVMElf32SymbolTableEntry >> value: anObject [
	value := anObject
]

{ #category : #writing }
SLVMElf32SymbolTableEntry >> writeOn: aStream [
	aStream
		nextPutInt32: name;
		nextPutInt32: value;
		nextPutInt32: size;
		nextPutInt8: info;
		nextPutInt8: other;
		nextPutInt16: sectionHeaderIndex.
]

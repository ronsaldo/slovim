Class {
	#name : #SLVMElf64SymbolTableEntry,
	#superclass : #SLVMElf32SymbolTableEntry,
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #'as yet unclassified' }
SLVMElf64SymbolTableEntry class >> entrySize [
	^ 24
]

{ #category : #writing }
SLVMElf64SymbolTableEntry >> writeOn: aStream [
	aStream
		nextPutInt32: name;
		nextPutInt8: info;
		nextPutInt8: other;
		nextPutInt16: sectionHeaderIndex;
		nextPutInt64: value;
		nextPutInt64: size.
]

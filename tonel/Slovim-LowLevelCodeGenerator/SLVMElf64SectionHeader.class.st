Class {
	#name : #SLVMElf64SectionHeader,
	#superclass : #SLVMElf32SectionHeader,
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #types }
SLVMElf64SectionHeader >> dynsym [
	type := 11.
	entrySize := 24.
]

{ #category : #accessing }
SLVMElf64SectionHeader >> size [
	^ 64
]

{ #category : #types }
SLVMElf64SectionHeader >> symbolTable [
	type := 2.
	entrySize := 24.
]

{ #category : #writing }
SLVMElf64SectionHeader >> writeOn: aStream [
	aStream
		nextPutInt32: name;
		nextPutInt32: type;
		nextPutInt64: flags;
		nextPutInt64: address;
		nextPutInt64: offset;
		nextPutInt64: size;
		nextPutInt32: link;
		nextPutInt32: info;
		nextPutInt64: addressAlign;
		nextPutInt64: entrySize.
]

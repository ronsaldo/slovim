Class {
	#name : #SLVMElf64Header,
	#superclass : #SLVMElf32Header,
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #'as yet unclassified' }
SLVMElf64Header >> size [
	^ 64
]

{ #category : #'as yet unclassified' }
SLVMElf64Header >> writeOn: aStream [
	aStream
		"Magic"
		nextPutInt8: 16r7F;
		nextPutInt8: 16r45;
		nextPutInt8: 16r4c;
		nextPutInt8: 16r46;
		
		"Elf class"
		nextPutInt8: 16r02;

		"Endianness"
		nextPutInt8: endianness;
		
		"Version"
		nextPutInt8: 16r01;
		
		nextPutInt8: osAbi;
		nextPutInt8: abiVersion.

	"Padding"
	1 to: 7 do: [:i | aStream nextPutInt8: 16r00 ].
	
	aStream
		nextPutInt16: type;
		nextPutInt16: machine;
		nextPutInt32: 1;
		nextPutInt64: entryPoint;
		nextPutInt64: programHeaderOffset;
		nextPutInt64: sectionHeaderOffset;
		nextPutInt32: flags;
		nextPutInt16: self size;
		nextPutInt16: self programHeaderEntrySize;
		nextPutInt16: programHeaderEntries;
		nextPutInt16: self sectionHeaderEntrySize;
		nextPutInt16: sectionHeaderEntries;
		nextPutInt16: sectionNameStringSectionIndex
]

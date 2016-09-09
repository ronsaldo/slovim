Class {
	#name : #SLVMElf32Header,
	#superclass : #SLVMLirBinaryFileComponent,
	#instVars : [
		'endianness',
		'osAbi',
		'abiVersion',
		'type',
		'machine',
		'entryPoint',
		'programHeaderOffset',
		'sectionHeaderOffset',
		'flags',
		'programHeaderEntries',
		'sectionHeaderEntries',
		'sectionNameStringSectionIndex'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #accessing }
SLVMElf32Header >> abiVersion [
	^ abiVersion
]

{ #category : #accessing }
SLVMElf32Header >> abiVersion: anObject [
	abiVersion := anObject
]

{ #category : #'elf type' }
SLVMElf32Header >> core [
	type := 4.
]

{ #category : #accessing }
SLVMElf32Header >> endianness [
	^ endianness
]

{ #category : #accessing }
SLVMElf32Header >> endianness: anObject [
	endianness := anObject
]

{ #category : #accessing }
SLVMElf32Header >> entryPoint [
	^ entryPoint
]

{ #category : #accessing }
SLVMElf32Header >> entryPoint: anObject [
	entryPoint := anObject
]

{ #category : #'elf type' }
SLVMElf32Header >> executable [
	type := 2.
]

{ #category : #accessing }
SLVMElf32Header >> flags [
	^ flags
]

{ #category : #accessing }
SLVMElf32Header >> flags: anObject [
	flags := anObject
]

{ #category : #writing }
SLVMElf32Header >> initialize [
	super initialize.
	endianness := 1.
	osAbi := 0.
	abiVersion := 0.
	type := 1.
	machine := 0.
	entryPoint := 0.
	programHeaderOffset := 0.
	sectionHeaderOffset := 0.
	flags := 0.
	programHeaderEntries := 0.
	sectionHeaderEntries := 0.
	sectionNameStringSectionIndex := 0
]

{ #category : #accessing }
SLVMElf32Header >> machine [
	^ machine
]

{ #category : #accessing }
SLVMElf32Header >> machine: anObject [
	machine := anObject
]

{ #category : #accessing }
SLVMElf32Header >> osAbi [
	^ osAbi
]

{ #category : #accessing }
SLVMElf32Header >> osAbi: anObject [
	osAbi := anObject
]

{ #category : #accessing }
SLVMElf32Header >> programHeaderEntries [
	^ programHeaderEntries
]

{ #category : #accessing }
SLVMElf32Header >> programHeaderEntries: anObject [
	programHeaderEntries := anObject
]

{ #category : #writing }
SLVMElf32Header >> programHeaderEntrySize [
	^ 32
]

{ #category : #accessing }
SLVMElf32Header >> programHeaderOffset [
	^ programHeaderOffset
]

{ #category : #accessing }
SLVMElf32Header >> programHeaderOffset: anObject [
	programHeaderOffset := anObject
]

{ #category : #'elf type' }
SLVMElf32Header >> relocatable [
	type := 1.
]

{ #category : #accessing }
SLVMElf32Header >> sectionHeaderEntries [
	^ sectionHeaderEntries
]

{ #category : #accessing }
SLVMElf32Header >> sectionHeaderEntries: anObject [
	sectionHeaderEntries := anObject
]

{ #category : #writing }
SLVMElf32Header >> sectionHeaderEntrySize [
	^ 64
]

{ #category : #accessing }
SLVMElf32Header >> sectionHeaderOffset [
	^ sectionHeaderOffset
]

{ #category : #accessing }
SLVMElf32Header >> sectionHeaderOffset: anObject [
	sectionHeaderOffset := anObject
]

{ #category : #accessing }
SLVMElf32Header >> sectionNameStringSectionIndex [
	^ sectionNameStringSectionIndex
]

{ #category : #accessing }
SLVMElf32Header >> sectionNameStringSectionIndex: anObject [
	sectionNameStringSectionIndex := anObject
]

{ #category : #'elf type' }
SLVMElf32Header >> shared [
	type := 3.
]

{ #category : #accessing }
SLVMElf32Header >> size [
	^ 16r34
]

{ #category : #accessing }
SLVMElf32Header >> type [
	^ type
]

{ #category : #accessing }
SLVMElf32Header >> type: anObject [
	type := anObject
]

{ #category : #writing }
SLVMElf32Header >> writeOn: aStream [
	aStream
		"Magic"
		nextPutInt8: 16r7F;
		nextPutInt8: 16r45;
		nextPutInt8: 16r4c;
		nextPutInt8: 16r46;
		
		"Elf class"
		nextPutInt8: 16r01;

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
		nextPutInt32: entryPoint;
		nextPutInt32: programHeaderOffset;
		nextPutInt32: sectionHeaderOffset;
		nextPutInt32: flags;
		nextPutInt16: self size;
		nextPutInt16: self programHeaderEntrySize;
		nextPutInt16: programHeaderEntries;
		nextPutInt16: self sectionHeaderEntrySize;
		nextPutInt16: sectionHeaderEntries;
		nextPutInt16: sectionNameStringSectionIndex
]

Class {
	#name : #SLVMElf32SectionHeader,
	#superclass : #SLVMElfSectionHeader,
	#instVars : [
		'name',
		'type',
		'flags',
		'address',
		'offset',
		'size',
		'link',
		'info',
		'addressAlign',
		'entrySize'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #accessing }
SLVMElf32SectionHeader >> address [
	^ address
]

{ #category : #accessing }
SLVMElf32SectionHeader >> address: anObject [
	address := anObject
]

{ #category : #accessing }
SLVMElf32SectionHeader >> addressAlign [
	^ addressAlign
]

{ #category : #accessing }
SLVMElf32SectionHeader >> addressAlign: anObject [
	addressAlign := anObject
]

{ #category : #flags }
SLVMElf32SectionHeader >> allocated [
	flags := flags | 2
]

{ #category : #types }
SLVMElf32SectionHeader >> dynamics [
	type := 6
]

{ #category : #types }
SLVMElf32SectionHeader >> dynsym [
	type := 11.
	entrySize := 16.
]

{ #category : #flags }
SLVMElf32SectionHeader >> executableInstructions [
	flags := flags | 4
]

{ #category : #accessing }
SLVMElf32SectionHeader >> flags [
	^ flags
]

{ #category : #accessing }
SLVMElf32SectionHeader >> flags: anObject [
	flags := anObject
]

{ #category : #types }
SLVMElf32SectionHeader >> hash [
	type := 5
]

{ #category : #accessing }
SLVMElf32SectionHeader >> info [
	^ info
]

{ #category : #accessing }
SLVMElf32SectionHeader >> info: anObject [
	info := anObject
]

{ #category : #initialization }
SLVMElf32SectionHeader >> initialize [
	super initialize.
	name := 0.
	type := 0.
	flags := 0.
	address := 0.
	offset := 0.
	size := 0.
	link := 0.
	info := 0.
	addressAlign := 1.
	entrySize := 0.
]

{ #category : #flags }
SLVMElf32SectionHeader >> isAllocated [
	^ flags anyMask: 2
]

{ #category : #accessing }
SLVMElf32SectionHeader >> link [
	^ link
]

{ #category : #accessing }
SLVMElf32SectionHeader >> link: anObject [
	link := anObject
]

{ #category : #accessing }
SLVMElf32SectionHeader >> name [
	^ name
]

{ #category : #accessing }
SLVMElf32SectionHeader >> name: anObject [
	name := anObject
]

{ #category : #types }
SLVMElf32SectionHeader >> nobits [
	type := 8
]

{ #category : #types }
SLVMElf32SectionHeader >> note [
	type := 7
]

{ #category : #accessing }
SLVMElf32SectionHeader >> offset [
	^ offset
]

{ #category : #accessing }
SLVMElf32SectionHeader >> offset: anObject [
	offset := anObject
]

{ #category : #types }
SLVMElf32SectionHeader >> programBits [
	type := 1
]

{ #category : #types }
SLVMElf32SectionHeader >> rel [
	type := 9
]

{ #category : #types }
SLVMElf32SectionHeader >> rela [
	type := 4
]

{ #category : #types }
SLVMElf32SectionHeader >> shlib [
	type := 10
]

{ #category : #accessing }
SLVMElf32SectionHeader >> size [
	^ 40
]

{ #category : #accessing }
SLVMElf32SectionHeader >> size1 [
	^ size
]

{ #category : #accessing }
SLVMElf32SectionHeader >> size: anObject [
	size := anObject
]

{ #category : #types }
SLVMElf32SectionHeader >> stringTable [
	type := 3
]

{ #category : #types }
SLVMElf32SectionHeader >> symbolTable [
	type := 2.
	entrySize := 16.
]

{ #category : #accessing }
SLVMElf32SectionHeader >> type [
	^ type
]

{ #category : #accessing }
SLVMElf32SectionHeader >> type: anObject [
	type := anObject
]

{ #category : #writing }
SLVMElf32SectionHeader >> writeOn: aStream [
	aStream
		nextPutInt32: name;
		nextPutInt32: type;
		nextPutInt32: flags;
		nextPutInt32: address;
		nextPutInt32: offset;
		nextPutInt32: size;
		nextPutInt32: link;
		nextPutInt32: info;
		nextPutInt32: addressAlign;
		nextPutInt32: entrySize.
]

{ #category : #flags }
SLVMElf32SectionHeader >> writeable [
	flags := flags | 1
]

Class {
	#name : #SLVMElfBuilder,
	#superclass : #Object,
	#instVars : [
		'components',
		'header',
		'sectionNameTable',
		'sections',
		'symbolStringTable',
		'symbolTable',
		'dynSymbolStringTable',
		'dynSymbolTable',
		'firstComponents',
		'sectionIndexDictionary'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #adding }
SLVMElfBuilder >> addComponent: component [
	components add: component.
	^ component
]

{ #category : #adding }
SLVMElfBuilder >> addComponent: component sectionNamed: sectionNamed [
	^ self addSectionNamed: sectionNamed content: (self addComponent: component)
]

{ #category : #adding }
SLVMElfBuilder >> addDynamicSymbol: symbol [
	dynSymbolTable ifNil: [ ^ nil ].
	dynSymbolTable addSymbol: symbol stringTable: dynSymbolStringTable sectionDictionary: sectionIndexDictionary
]

{ #category : #adding }
SLVMElfBuilder >> addFirstComponent: component [
	firstComponents add: component.
	^ component
]

{ #category : #adding }
SLVMElfBuilder >> addFirstComponent: component sectionNamed: sectionNamed [
	^ self addSectionNamed: sectionNamed content: (self addFirstComponent: component)
]

{ #category : #adding }
SLVMElfBuilder >> addNormalSymbol: symbol [
	symbolTable ifNil: [ ^ nil ].
	symbolTable addSymbol: symbol stringTable: symbolStringTable sectionDictionary: sectionIndexDictionary
]

{ #category : #adding }
SLVMElfBuilder >> addSectionNamed: sectionName [
	^ self addSectionNamed: sectionName content: nil
]

{ #category : #adding }
SLVMElfBuilder >> addSectionNamed: sectionName content: content [
	| section |
	section := self sectionHeaderClass new
		name: (sectionNameTable addString: sectionName);
		content: content;
		index: sections size.
	sections add: section.
	content ifNotNil: [ sectionIndexDictionary at: content put: section index ].
	^ section
]

{ #category : #adding }
SLVMElfBuilder >> addSymbol: symbol [
	self addDynamicSymbol: symbol;
		addNormalSymbol: symbol
]

{ #category : #writing }
SLVMElfBuilder >> allComponentsDo: aBlock [
	aBlock value: header.
	firstComponents do: aBlock.
	components do: aBlock.
	sections do: aBlock.
]

{ #category : #'as yet unclassified' }
SLVMElfBuilder >> binaryData [
	| stream |
	stream := SLVMLirBinaryStream on: (ByteArray new: 100).
	self writeToStream: stream.
	^ stream contents
]

{ #category : #'as yet unclassified' }
SLVMElfBuilder >> computeFileBinaryElementsOffsets [
	| offset |
	offset := 0.
	self allComponentsDo: [ :component |
		component fileOffset: offset.
		offset := offset + component size
	]
]

{ #category : #adding }
SLVMElfBuilder >> createDynSymbolTable [
	| stringTableSection |
	dynSymbolStringTable := self addComponent: SLVMElfStringTable new.
	stringTableSection := (self addSectionNamed: '.dynstr' content: dynSymbolStringTable)
		stringTable.
		
	dynSymbolTable := self addComponent: self symbolTableClass new.
	(self addSectionNamed: '.dyntab' content: dynSymbolTable)
		link: stringTableSection index;
		dynsym;
		allocated
]

{ #category : #adding }
SLVMElfBuilder >> createSymbolTable [
	| stringTableSection |
	symbolStringTable := self addComponent: SLVMElfStringTable new.
	stringTableSection := (self addSectionNamed: '.strtab' content: symbolStringTable)
		stringTable.
		
	symbolTable := self addComponent: self symbolTableClass new.
	(self addSectionNamed: '.symtab' content: symbolTable)
		link: stringTableSection index;
		symbolTable;
		allocated.
]

{ #category : #accessing }
SLVMElfBuilder >> header [
	^ header
]

{ #category : #'format classes' }
SLVMElfBuilder >> headerClass [
	self subclassResponsibility
]

{ #category : #initialization }
SLVMElfBuilder >> initialize [
	super initialize.
	firstComponents := OrderedCollection new.
	components := OrderedCollection new.
	sections := OrderedCollection new.
	sectionIndexDictionary := IdentityDictionary new.
	sections add: self sectionHeaderClass new.	"Null section."
		
	header := self headerClass new.
	sectionNameTable := self addComponent: self stringTableClass new.
	(self addSectionNamed: '.shstrtab' content: sectionNameTable)
		stringTable.
]

{ #category : #writing }
SLVMElfBuilder >> prepareForWriting [
	| address |
	self computeFileBinaryElementsOffsets.
	address := 0.
	self allComponentsDo: [:component |
		address := component prepareForWritingToFile: address
	].
	
	header
		sectionHeaderOffset: sections first fileOffset;
		sectionHeaderEntries: sections size;
		sectionNameStringSectionIndex: 1.
]

{ #category : #'format classes' }
SLVMElfBuilder >> programHeaderClass [
	self subclassResponsibility
]

{ #category : #'format classes' }
SLVMElfBuilder >> sectionHeaderClass [
	self subclassResponsibility
]

{ #category : #'format classes' }
SLVMElfBuilder >> stringTableClass [
	self subclassResponsibility
]

{ #category : #'format classes' }
SLVMElfBuilder >> symbolTableClass [
	self subclassResponsibility
]

{ #category : #'format classes' }
SLVMElfBuilder >> symbolTableEntryClass [
	self subclassResponsibility
]

{ #category : #writing }
SLVMElfBuilder >> writeToFileNamed: fileName [
	| data |
	data := self binaryData.
	fileName asFileReference writeStreamDo: [ :out |
		out truncate; binary; nextPutAll: data
	]
]

{ #category : #writing }
SLVMElfBuilder >> writeToStream: stream [
	self prepareForWriting.
	self allComponentsDo: [ :el | el writeOn: stream ].
]

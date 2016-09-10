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
		'sectionIndexDictionary',
		'sectionDictionary',
		'relocationSectionDictionary',
		'symbolDictionary',
		'sectionContentDictionary'
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
	| elfSymbol |
	symbolTable ifNil: [ ^ nil ].
	elfSymbol := symbolTable addSymbol: symbol stringTable: symbolStringTable sectionDictionary: sectionIndexDictionary.
	symbolDictionary at: symbol put: elfSymbol index.
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
	content ifNotNil: [
		sectionContentDictionary at: content put: section.
		sectionIndexDictionary at: content put: section index.
	].
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
	symbolTable sectionHeader: ((self addSectionNamed: '.dyntab' content: dynSymbolTable)
		link: stringTableSection index;
		addressAlign: self pointerAlignment;
		dynsym;
		allocated)
]

{ #category : #adding }
SLVMElfBuilder >> createSymbolTable [
	| stringTableSection |
	symbolStringTable := self addComponent: SLVMElfStringTable new.
	stringTableSection := (self addSectionNamed: '.strtab' content: symbolStringTable)
		stringTable.
		
	symbolTable := self addComponent: self symbolTableClass new.
	symbolTable sectionHeader: ((self addSectionNamed: '.symtab' content: symbolTable)
		link: stringTableSection index;
		addressAlign: self pointerAlignment;
		symbolTable;
		allocated).
]

{ #category : #accessing }
SLVMElfBuilder >> header [
	^ header
]

{ #category : #'format classes' }
SLVMElfBuilder >> headerClass [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMElfBuilder >> indexOfRelocationSymbol: symbol section: section [
	symbol ifNil: [ 
		^ symbolDictionary at: section ifAbsentPut: [ 
			(symbolTable addRelocationSectionSymbol: section)
				index
		]
	].

	^ self indexOfSymbol: symbol
]

{ #category : #accessing }
SLVMElfBuilder >> indexOfSymbol: symbol [
	^ symbolDictionary at: symbol
]

{ #category : #initialization }
SLVMElfBuilder >> initialize [
	super initialize.
	firstComponents := OrderedCollection new.
	components := OrderedCollection new.
	sections := OrderedCollection new.
	sectionContentDictionary := IdentityDictionary new.
	sectionIndexDictionary := IdentityDictionary new.
	relocationSectionDictionary := IdentityDictionary new.
	symbolDictionary := IdentityDictionary new.
	sections add: self sectionHeaderClass new.	"Null section."
		
	header := self headerClass new.
	sectionNameTable := self addComponent: self stringTableClass new.
	(self addSectionNamed: '.shstrtab' content: sectionNameTable)
		stringTable.
]

{ #category : #accessing }
SLVMElfBuilder >> pointerAlignment [
	self subclassResponsibility
]

{ #category : #writing }
SLVMElfBuilder >> prepareForWriting [
	self computeFileBinaryElementsOffsets.
	self allComponentsDo: [:component |
		component prepareForWritingToFile
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

{ #category : #adding }
SLVMElfBuilder >> relocationSectionFor: section [
	^ (relocationSectionDictionary at: section ifAbsentPut: [
		(self addSectionNamed: ('.rel' , section name) asSymbol content: (self addComponent: self relocationTableClass new))
			rel;
			setInfoAndLinkFlags;
			addressAlign: self pointerAlignment;
			link: (sectionIndexDictionary at: symbolTable);
			info: (sectionIndexDictionary at: section);
			yourself
	]) content
]

{ #category : #'format classes' }
SLVMElfBuilder >> relocationTableClass [
	self subclassResponsibility
]

{ #category : #adding }
SLVMElfBuilder >> relocationWithAddendSectionFor: section [
	^ relocationSectionDictionary at: section ifAbsentPut: [
		(self addSectionNamed: ('.rela' , section name) asSymbol content: (self addComponent: self relocationWithAddendTableClass new))
			rela;
			link: (sectionIndexDictionary at: symbolTable);
			info: (sectionIndexDictionary at: section);
			yourself
	]
]

{ #category : #'format classes' }
SLVMElfBuilder >> relocationWithAddendTableClass [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMElfBuilder >> sectionFromContent: content [
	content ifNil: [ ^ nil ].
	^ sectionContentDictionary at: content
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

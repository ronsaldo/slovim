Class {
	#name : #SLVMLirMachineCode,
	#superclass : #Object,
	#instVars : [
		'compilationTarget',
		'sections',
		'symbols',
		'moduleType'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #comparing }
SLVMLirMachineCode >> = other [
	^ self class = other class and:
	[ sections = other sections and:
	[ symbols = other symbols and:
	[ compilationTarget = other compilationTarget ] ] ]
]

{ #category : #accessing }
SLVMLirMachineCode >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMLirMachineCode >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #writing }
SLVMLirMachineCode >> computeFileBinaryElementsOffsets: elements [
	| offset |
	offset := 0.
	elements do: [ :element | element fileOffset: offset. offset := offset + element size ]
]

{ #category : #writing }
SLVMLirMachineCode >> generateElf32 [
	| stream |
	stream := SLVMLirBinaryStream on: (ByteArray new: 100).
	self writeElf32ToStream: stream.
	^ stream contents
]

{ #category : #initialization }
SLVMLirMachineCode >> initialize [
	super initialize.
	moduleType := #object.
]

{ #category : #testing }
SLVMLirMachineCode >> isFullProgram [
	^ moduleType == #program
]

{ #category : #testing }
SLVMLirMachineCode >> isObjectCode [
	^ moduleType == #object
]

{ #category : #accessing }
SLVMLirMachineCode >> sections [
	^ sections
]

{ #category : #accessing }
SLVMLirMachineCode >> sections: anObject [
	sections := anObject
]

{ #category : #accessing }
SLVMLirMachineCode >> symbols [
	^ symbols
]

{ #category : #accessing }
SLVMLirMachineCode >> symbols: anObject [
	symbols := anObject
]

{ #category : #writing }
SLVMLirMachineCode >> writeBinaryToFile: aFileName [
	aFileName asFileReference writeStreamDo: [ :out |
		out truncate; binary.
		self writeFlatSectionDataOn: out 
	]
]

{ #category : #writing }
SLVMLirMachineCode >> writeElf32ToFile: fileName [
	fileName asFileReference writeStreamDo: [ :out |
		out truncate; binary.
		out nextPutAll: self generateElf32
	]
]

{ #category : #writing }
SLVMLirMachineCode >> writeElf32ToStream: stream [
	| header elfSections allElements sectionNameTable sectionNameTableSection allElfSections symbolStringTable symbolStringTableSection dynSymbolStringTable dynSymbolStringTableSection dynSymbolTable dynSymbolTableSection symbolTable symbolTableSection elfSectionIndexDictionary baseElfSections |
	header := SLVMElf32Header new.
	
	sectionNameTable := SLVMElfStringTable new.
	sectionNameTableSection := SLVMElf32SectionHeader new
		name: (sectionNameTable addString:'.shstrtab');
		stringTable;
		yourself.
		
	self isObjectCode ifFalse: [
		dynSymbolStringTable := SLVMElfStringTable new.
		dynSymbolStringTableSection := SLVMElf32SectionHeader new
			name: (sectionNameTable addString:'.dynstr');
			stringTable;
			allocated;
			yourself.

		dynSymbolTable := SLVMElf32SymbolTable new.
		dynSymbolTableSection := SLVMElf32SectionHeader new
			name: (sectionNameTable addString:'.dyntab');
			symbolTable;
			allocated;
			yourself.
	].
		
	symbolStringTable := SLVMElfStringTable new.
	symbolStringTableSection := SLVMElf32SectionHeader new
		name: (sectionNameTable addString:'.strtab');
		stringTable;
		yourself.

	symbolTable := SLVMElf32SymbolTable new.
	symbolTableSection := SLVMElf32SectionHeader new
		name: (sectionNameTable addString:'.symtab');
		symbolTable;
		yourself.
		
	elfSections := sections collect: [ :section |
		| elfSection |
		elfSection := SLVMElf32SectionHeader new
			name: (sectionNameTable addString: section name);
			programBits;
			allocated;
			address: section base;
			size: section size;
			yourself.
		section name = #'.text' ifTrue: [ elfSection executableInstructions ].
		(section name = #'.data' or: [ section name = #'.bss' ]) ifTrue: [ elfSection writeable ].
		elfSection
	].

	baseElfSections := { SLVMElf32SectionHeader new .
		sectionNameTableSection .
		symbolTableSection . symbolStringTableSection . }.
	dynSymbolTableSection ifNotNil: [
		baseElfSections := baseElfSections , { dynSymbolTableSection . dynSymbolStringTableSection }.
	].

	allElfSections := baseElfSections , elfSections.
	symbolTableSection link: (allElfSections indexOf: symbolStringTableSection) - 1.
	dynSymbolTableSection ifNotNil: [
		dynSymbolTableSection link: (allElfSections indexOf: dynSymbolStringTableSection) - 1.
	].

	"Translate the symbol table"
	elfSectionIndexDictionary := Dictionary new.
	elfSections doWithIndex: [ :elfSection :sectionIndex |
		elfSectionIndexDictionary at: (sections at: sectionIndex) put: (allElfSections indexOf: elfSection) - 1
	].

	symbols do: [ :symbol |
		dynSymbolTable ifNotNil: [
			dynSymbolTable addSymbol: symbol stringTable: dynSymbolStringTable sectionDictionary: elfSectionIndexDictionary.
		].
		symbolTable addSymbol: symbol stringTable: symbolStringTable sectionDictionary: elfSectionIndexDictionary.
	].

	"Compute the final location of the elements."
	allElements := { header } , sections ,
	{ sectionNameTable .
	 symbolTable . symbolStringTable }.
	dynSymbolTable ifNotNil: [
		allElements := allElements , { dynSymbolTable . dynSymbolStringTable }.
	].
	allElements := allElements , allElfSections.
	self computeFileBinaryElementsOffsets: allElements.
	
	sections doWithIndex: [ :section :index |
		(elfSections at: index)
			offset: section fileOffset
	].
 
	header
		machine: compilationTarget elfMachine;
		sectionHeaderOffset: allElfSections first fileOffset;
		sectionHeaderEntries: allElfSections size;
		sectionNameStringSectionIndex: 1.
		
	sectionNameTableSection
		offset: sectionNameTable fileOffset;
		size: sectionNameTable size.

	dynSymbolTable ifNotNil: [
		dynSymbolStringTableSection 
			offset: dynSymbolStringTable fileOffset;
			size: dynSymbolStringTable size.
			
		dynSymbolTableSection
			offset: dynSymbolTable fileOffset;
			size: dynSymbolTable size.
	].

	symbolStringTableSection 
		offset: symbolStringTable fileOffset;
		size: symbolStringTable size.
			
	symbolTableSection
		offset: symbolTable fileOffset;
		size: symbolTable size.

	allElements do: [ :el | el writeOn: stream ].
]

{ #category : #writing }
SLVMLirMachineCode >> writeElf64ToFile: fileName [
]

{ #category : #writing }
SLVMLirMachineCode >> writeFlatSectionDataOn: aStream [
	sections do: [ :section | aStream nextPutAll: section code ]
]

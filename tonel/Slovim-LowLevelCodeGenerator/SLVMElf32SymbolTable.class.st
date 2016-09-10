Class {
	#name : #SLVMElf32SymbolTable,
	#superclass : #SLVMLirBinaryFileComponent,
	#instVars : [
		'sectionHeader',
		'entries',
		'localEntries'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #adding }
SLVMElf32SymbolTable >> addRelocationSectionSymbol: section [
	| elfSymbol binding type |
	binding := 0.
	type := 3.
	elfSymbol := self symbolEntryClass new
		name: 0;
		value: 0;
		info: binding << 4 | (type bitAnd: 16rf);
		sectionHeaderIndex: section index;
		index: localEntries size.
	localEntries add: elfSymbol.
	^ elfSymbol
]

{ #category : #adding }
SLVMElf32SymbolTable >> addSymbol: symbol stringTable: stringTable sectionDictionary: sectionIndexDictionary [
	| elfSymbol binding type |
	binding := symbol isPublic
		ifTrue: [ 1 ]
		ifFalse: [ symbol isWeak ifTrue: [ 2 ] ifFalse: [ 0 ] ].
	type := 0.
	symbol type == #function ifTrue: [ 
		type := 2
	].

	elfSymbol := self symbolEntryClass new
		name: (symbol isPrivate ifTrue: [ 0 ] ifFalse: [ stringTable addString: symbol name ]);
		value: symbol position;
		size: symbol size;
		info: binding << 4 | (type bitAnd: 16rf);
		sectionHeaderIndex: (sectionIndexDictionary at: symbol section).
	binding = 0 ifTrue: [
		elfSymbol index: localEntries size.
		localEntries add: elfSymbol
	] ifFalse: [
		elfSymbol index: entries size.
		entries add: elfSymbol
	].

	^ elfSymbol
]

{ #category : #initialization }
SLVMElf32SymbolTable >> initialize [
	super initialize.
	localEntries := OrderedCollection new.
	localEntries add: self symbolEntryClass new.
	entries := OrderedCollection new.
]

{ #category : #writing }
SLVMElf32SymbolTable >> prepareForWritingToFile [
	super prepareForWritingToFile.
	sectionHeader info: localEntries size.
]

{ #category : #accessing }
SLVMElf32SymbolTable >> sectionHeader [
	^ sectionHeader
]

{ #category : #accessing }
SLVMElf32SymbolTable >> sectionHeader: anObject [
	sectionHeader := anObject
]

{ #category : #accessing }
SLVMElf32SymbolTable >> size [
	^ self symbolEntryClass entrySize * (localEntries size + entries size)
]

{ #category : #factory }
SLVMElf32SymbolTable >> symbolEntryClass [
	^ SLVMElf32SymbolTableEntry
]

{ #category : #writing }
SLVMElf32SymbolTable >> writeOn: aStream [
	localEntries do: [ :entry | entry writeOn: aStream ].
	entries do: [ :entry | entry writeOn: aStream ]
]

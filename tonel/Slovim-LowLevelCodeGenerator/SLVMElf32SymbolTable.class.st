Class {
	#name : #SLVMElf32SymbolTable,
	#superclass : #SLVMLirBinaryFileComponent,
	#instVars : [
		'entries'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #adding }
SLVMElf32SymbolTable >> addSymbol: symbol stringTable: stringTable sectionDictionary: sectionIndexDictionary [
	| elfSymbol binding type |
	binding := symbol isPublic
		ifTrue: [ 1 ]
		ifFalse: [ symbol isWeak ifTrue: [ 2 ] ifFalse: [ 0 ] ].
	type := 0.
	elfSymbol := self symbolEntryClass new
		name: (symbol isPrivate ifTrue: [ 0 ] ifFalse: [ stringTable addString: symbol name ]);
		value: symbol position;
		size: symbol size;
		info: binding << 4 | (type bitAnd: 16rf);
		sectionHeaderIndex: (sectionIndexDictionary at: symbol section).
	entries add: elfSymbol
]

{ #category : #initialization }
SLVMElf32SymbolTable >> initialize [
	super initialize.
	entries := OrderedCollection new.
	entries add: self symbolEntryClass new.
]

{ #category : #accessing }
SLVMElf32SymbolTable >> size [
	^ self symbolEntryClass entrySize * entries size
]

{ #category : #factory }
SLVMElf32SymbolTable >> symbolEntryClass [
	^ SLVMElf32SymbolTableEntry
]

{ #category : #writing }
SLVMElf32SymbolTable >> writeOn: aStream [
	entries do: [ :entry | entry writeOn: aStream ]
]

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

{ #category : #writing }
SLVMLirMachineCode >> buildElfOn: builder [
	| elfSection |
	builder header 
		machine: compilationTarget elfMachine.
	builder createSymbolTable.
	self isObjectCode ifFalse: [
		builder createDynSymbolTable.
	].

	sections do: [ :section |
		elfSection := builder addFirstComponent: section sectionNamed: section name.
		elfSection programBits; allocated.
		elfSection address: section base.
		"Ensure the local symbols come before the globals."
		builder indexOfRelocationSymbol: nil section: elfSection.
		
		(#('.text' '.oopRegistration') includes: section name) ifTrue: [ elfSection executableInstructions ].
		(#('.bss' '.data' '.oop') includes: section name) ifTrue: [
			elfSection
				writeable;
				addressAlign: 16
		].
		(#('.text' '.rodata') includes: section name) ifTrue: [
			elfSection
				addressAlign: 16
		].

		section name = #'.bss' ifTrue: [ elfSection nobits ].
	].

	symbols do: [ :symbol |
		builder addSymbol: symbol.
	].

	sections do: [ :section |
		section relocations do: [ :relocation |
			compilationTarget convertRelocation: relocation section: section elfBuilder: builder
		]
	]
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

{ #category : #writing }
SLVMLirMachineCode >> generateElf64 [
	| stream |
	stream := SLVMLirBinaryStream on: (ByteArray new: 100).
	self writeElf64ToStream: stream.
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
	| builder |
	builder := SLVMElf32Builder new.
	self buildElfOn: builder.
	builder writeToStream: stream
]

{ #category : #writing }
SLVMLirMachineCode >> writeElf64ToFile: fileName [
	fileName asFileReference writeStreamDo: [ :out |
		out truncate; binary.
		out nextPutAll: self generateElf64
	]
]

{ #category : #writing }
SLVMLirMachineCode >> writeElf64ToStream: stream [
	| builder |
	builder := SLVMElf64Builder new.
	self buildElfOn: builder.
	builder writeToStream: stream
]

{ #category : #writing }
SLVMLirMachineCode >> writeElfToFile: fileName [
	compilationTarget usesElf64 ifTrue: [
		self writeElf64ToFile: fileName
	] ifFalse: [
		self writeElf32ToFile: fileName
	]
]

{ #category : #writing }
SLVMLirMachineCode >> writeFlatSectionDataOn: aStream [
	sections do: [ :section | aStream nextPutAll: section code ]
]

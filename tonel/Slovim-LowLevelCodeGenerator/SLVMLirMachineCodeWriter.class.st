Class {
	#name : #SLVMLirMachineCodeWriter,
	#superclass : #Object,
	#instVars : [
		'stream',
		'currentSection',
		'sections',
		'symbols',
		'symbolTable',
		'currentSectionSource',
		'compilationTarget',
		'sectionDictionary',
		'lastSection'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #'as yet unclassified' }
SLVMLirMachineCodeWriter class >> do: aBlock [
	^ self new do: aBlock
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> addSymbol: symbol [
	symbols add: symbol.
	^ symbol
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> addSymbol: symbol withDestination: destination addendToReloc: reloc [
	symbol shouldBeKeep ifFalse: [
		reloc addend: reloc addend + destination relocatableValue
	]
]

{ #category : #accessing }
SLVMLirMachineCodeWriter >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMLirMachineCodeWriter >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #accessing }
SLVMLirMachineCodeWriter >> currentSection [
	^ currentSection
]

{ #category : #enumerating }
SLVMLirMachineCodeWriter >> do: aBlock [
	aBlock value: self.
	^ SLVMLirMachineCode new
		sections: sections;
		symbols: (symbols select: #shouldBeKeep)
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> getOrCreateSectionNamed: sectionName [
	| section |
	^ sectionDictionary at: sectionName ifAbsentPut: [
		section := SLVMLirMachineCodeSection new name: sectionName.
		sections add: section.
		section
	]
]

{ #category : #'as yet unclassified' }
SLVMLirMachineCodeWriter >> hasBaseLoadingAddress [
	^ false
]

{ #category : #initialization }
SLVMLirMachineCodeWriter >> initialize [
	super initialize.
	sections := OrderedCollection new.
	symbols := OrderedCollection new.
	symbolTable := Dictionary new.
	sectionDictionary := Dictionary new.
]

{ #category : #'as yet unclassified' }
SLVMLirMachineCodeWriter >> lastSectionEnding [
	lastSection ifNil: [ ^ 0 ].
	^ lastSection base + lastSection size
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> nextPut: value [
	stream nextPut: value
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> nextPutAll: value [
	stream nextPutAll: value
]

{ #category : #accessing }
SLVMLirMachineCodeWriter >> position [
	^ stream position + currentSection base
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> put: value [
	stream nextPut: value
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putIPRelativeLabel: label [
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putInt16: value [
	self
		put: (value bitAnd: 16rff);
		put: ((value >> 8) bitAnd: 16rff)
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putInt32: value [
	self
		put: (value bitAnd: 16rff);
		put: ((value >> 8) bitAnd: 16rff);
		put: ((value >> 16) bitAnd: 16rff);
		put: ((value >> 24) bitAnd: 16rff).
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putInt64: value [
	self
		put: (value bitAnd: 16rff);
		put: ((value >> 8) bitAnd: 16rff);
		put: ((value >> 16) bitAnd: 16rff);
		put: ((value >> 24) bitAnd: 16rff);
		put: ((value >> 32) bitAnd: 16rff);
		put: ((value >> 40) bitAnd: 16rff);
		put: ((value >> 48) bitAnd: 16rff);
		put: ((value >> 56) bitAnd: 16rff).
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putInt8: value [
	self put: (value bitAnd: 16rFF)
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putMaybeReloc32: value [
	(value isInteger or: [ value isImmediateConstant ]) ifTrue: [
		^ self putInt32: value value
	].

	value isExternalLabel ifTrue: [
		^ self recordReloc32AndWriteValue: value addend: 0
	].

	value isLabel ifTrue: [
		^ self recordReloc32AndWriteValue: value addend: 0
	].

	value isLabelValue ifTrue: [
		^ self recordReloc32AndWriteValue: value label addend: value labelOffset
	].

	self halt.
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putMaybeReloc32: value nextIPRelative: immediateSize [
	^ self putMaybeRelocRelative32: value addend: -4 - immediateSize 
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putMaybeReloc64: value [
	(value isInteger or: [ value isImmediateConstant ]) ifTrue: [
		^self putInt64: value value
	].

	value isExternalLabel ifTrue: [
		^ self recordReloc64AndWriteValue: value addend: 0
	].

	value isLabel ifTrue: [
		^ self recordReloc64AndWriteValue: value addend: 0
	].

	value isLabelValue ifTrue: [
		^ self recordReloc64AndWriteValue: value label addend: value labelOffset
	].

	self halt.
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putMaybeRelocRelative32: value addend: addend [
	(value isInteger or: [ value isImmediateConstant ]) ifTrue: [
		^ self putInt32: value value
	].

	value isExternalLabel ifTrue: [
		^ self recordRelativeReloc32AndWriteValue: value addend: addend
	].

	value isLabel ifTrue: [
		^ self recordRelativeReloc32AndWriteValue: value addend: addend
	].

	value isLabelValue ifTrue: [
		^ self recordRelativeReloc32AndWriteValue: value label addend: value labelOffset + addend
	].

	self halt.
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putNextIPRelativeLabel32: label [
	^ self putMaybeRelocRelative32: label addend: -4
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putNextIPRelativeLabel8: label [
	self assert: label isExternalLabel not.
	self putInt8: label offset - (self position + 1)
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> recordLabel: label [
	label isExternalLabel ifTrue: [ 
		^ self symbolForLabel: label
	].

	^ (self symbolForLabel: label)
			visibility: label visibility;
			section: currentSection;
			position: stream position;
			size: label contentSize;
			type: label type;
			yourself.	
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> recordLabelEnd: label [
	| symbol |
	symbol := self symbolForLabel: label.
	symbol size: self position - symbol position.
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> recordRelativeReloc32AndWriteValue: value addend: addend [
	self recordRelativeRelocS32Into: value addend: addend.
	^ self putInt32: (value relocatableValueRelativeTo: self position) + addend
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> recordRelativeRelocS32Into: destinationLabel addend: addend [
	| symbol reloc |
	symbol := self symbolForLabel: destinationLabel.
	self assert: symbol isNotNil.
	reloc := SLVMLirMachineCodeRelocation new
		relativeSOffset32;
		offset: stream position;
		addend: addend;
		symbol: (symbol shouldBeKeep ifTrue: [ symbol ] ifFalse: [nil]);
		yourself.
	destinationLabel section ifNotNil: [
		reloc section: (self getOrCreateSectionNamed: destinationLabel section name).
	].
	self addSymbol: symbol withDestination: destinationLabel addendToReloc: reloc.

	currentSection addRelocation: reloc 
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> recordRelativeRelocS64Into: destinationLabel addend: addend [
	| symbol reloc |
	symbol := self symbolForLabel: destinationLabel.
	self assert: symbol isNotNil.
	reloc := SLVMLirMachineCodeRelocation new
		relativeSOffset64;
		offset: stream position;
		addend: addend;
		symbol: (symbol shouldBeKeep ifTrue: [ symbol ] ifFalse: [nil]);
		yourself.
	destinationLabel section ifNotNil: [
		reloc section: (self getOrCreateSectionNamed: destinationLabel section name).
	].
	self addSymbol: symbol withDestination: destinationLabel addendToReloc: reloc.

	currentSection addRelocation: reloc 
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> recordReloc32AndWriteValue: value addend: addend [
	self recordReloc32Into: value addend: addend.
	^ self putInt32: value relocatableValue + addend
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> recordReloc32Into: destinationLabel addend: addend [
	| symbol reloc |
	symbol := self symbolForLabel: destinationLabel.
	self assert: symbol isNotNil.
	reloc := SLVMLirMachineCodeRelocation new
		absoluteOffset32;
		offset: stream position;
		addend: addend;
		symbol: (symbol shouldBeKeep ifTrue: [ symbol ] ifFalse: [nil]);
		section: (destinationLabel section ifNotNil: [self getOrCreateSectionNamed: destinationLabel section name]);
		yourself.
	self addSymbol: symbol withDestination: destinationLabel addendToReloc: reloc.
	currentSection addRelocation: reloc.
	^ reloc
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> recordReloc64AndWriteValue: value addend: addend [
	self recordReloc32Into: value addend: addend.
	^ self putInt64: value relocatableValue + addend
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> recordReloc64Into: destinationLabel addend: addend [
	| symbol reloc |
	symbol := self symbolForLabel: destinationLabel.
	self assert: symbol isNotNil.
	reloc := SLVMLirMachineCodeRelocation new
		absoluteOffset64;
		offset: stream position;
		addend: addend;
		symbol: (symbol shouldBeKeep ifTrue: [ symbol ] ifFalse: [nil]);
		section: (destinationLabel section ifNotNil: [self getOrCreateSectionNamed: destinationLabel section name]);
		yourself.
	self addSymbol: symbol withDestination: destinationLabel addendToReloc: reloc.
	currentSection addRelocation: reloc 
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> section: section alignment: sectionAlignment do: aBlock [
	currentSectionSource := section. 
	currentSection := self getOrCreateSectionNamed: section name.
	self hasBaseLoadingAddress ifTrue: [ 
		currentSection base: (self lastSectionEnding alignedTo: sectionAlignment).
	] ifFalse: [
		currentSection base: 0
	].

	lastSection := currentSection.
	currentSection code: (ByteArray streamContents: [ :out |
		stream := out.
		aBlock value: self
	])
]

{ #category : #accessing }
SLVMLirMachineCodeWriter >> stream [
	^ stream
]

{ #category : #accessing }
SLVMLirMachineCodeWriter >> stream: anObject [
	stream := anObject
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> symbolForLabel: label [
	| result |
	^ symbolTable at: label ifAbsentPut: [
		result := SLVMLirMachineCodeSymbol new
			name: label name;
			yourself.
		label isExternalLabel ifTrue: [
			result
				visibility: label visibility;
				type: label type;
				position: 0;
				size: 0.
		].
	
		symbols add: result.
		result
	].
]

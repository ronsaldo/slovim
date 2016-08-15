Class {
	#name : #SLVMLirMachineCodeWriter,
	#superclass : #Object,
	#instVars : [
		'stream',
		'currentSection',
		'sections',
		'symbols',
		'symbolTable'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #'as yet unclassified' }
SLVMLirMachineCodeWriter class >> do: aBlock [
	^ self new do: aBlock
]

{ #category : #enumerating }
SLVMLirMachineCodeWriter >> do: aBlock [
	aBlock value: self.
	^ SLVMLirMachineCode new sections: sections; symbols: (symbols select: #shouldBeKeep) ; yourself
]

{ #category : #initialization }
SLVMLirMachineCodeWriter >> initialize [
	super initialize.
	sections := OrderedCollection new.
	symbols := OrderedCollection new.
	symbolTable := Dictionary new.
]

{ #category : #'as yet unclassified' }
SLVMLirMachineCodeWriter >> lastSectionEnding [
	sections ifEmpty: [ ^ 0 ].
	^ sections last base + sections code size
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
SLVMLirMachineCodeWriter >> putInt8: value [
	self put: (value bitAnd: 16rFF)
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putMaybeReloc32: value [
	value isInteger ifTrue: [
		self putInt32: value
	] ifFalse: [ 
		self halt.
	]
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putNextIPRelativeLabel32: label [
	self putInt32: label offset - (self position + 4)
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> putNextIPRelativeLabel8: label [
	self putInt8: label offset - (self position + 1)
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> recordLabel: label [
	(self symbolForLabel: label)
		visibility: label visibility;
		section: currentSection;
		position: stream position;
		yourself.	
]

{ #category : #adding }
SLVMLirMachineCodeWriter >> section: sectionName alignment: sectionAlignment do: aBlock [
	currentSection := SLVMLirMachineCodeSection new name: sectionName.
	currentSection base: (self lastSectionEnding alignedTo: sectionAlignment).
	sections add: currentSection.
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
		symbols add: result.
		result
	].
]

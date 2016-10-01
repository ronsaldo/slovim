Class {
	#name : #SLVMLirInstructionStream,
	#superclass : #Object,
	#instVars : [
		'compilationTarget',
		'sections',
		'currentSection'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #adding }
SLVMLirInstructionStream >> add: element [
	currentSection addLast: element
]

{ #category : #x86 }
SLVMLirInstructionStream >> addX86: opcode [
	^ self addX86: opcode operands: #()
]

{ #category : #x86 }
SLVMLirInstructionStream >> addX86: opcode operands: operands [
	self add: (SLVMLirX86Instruction new
		opcode: opcode;
		operands: operands;
		yourself
	)
]

{ #category : #x86 }
SLVMLirInstructionStream >> addX86: opcode with: operand [
	^ self addX86: opcode operands: {operand asLirInstructionOperand}
]

{ #category : #x86 }
SLVMLirInstructionStream >> addX86: opcode with: op1 with: op2 [
	^ self addX86: opcode operands: {op1 asLirInstructionOperand . op2 asLirInstructionOperand}
]

{ #category : #'as yet unclassified' }
SLVMLirInstructionStream >> asMachineCode [
	^ compilationTarget generateMachineCodeFromInstructionStream: self
]

{ #category : #accessing }
SLVMLirInstructionStream >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMLirInstructionStream >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #accessing }
SLVMLirInstructionStream >> currentSection [
	^ currentSection
]

{ #category : #accessing }
SLVMLirInstructionStream >> currentSection: anObject [
	currentSection := anObject
]

{ #category : #'as yet unclassified' }
SLVMLirInstructionStream >> currentSectionNamed: sectionName [
	^ self currentSection: (self getOrCreateSectionNamed: sectionName)
]

{ #category : #'as yet unclassified' }
SLVMLirInstructionStream >> getOrCreateSectionNamed: sectionName [
	^ sections at: sectionName ifAbsentPut: [
		SLVMLirInstructionStreamSection new
			name: sectionName
	]
]

{ #category : #'as yet unclassified' }
SLVMLirInstructionStream >> initialize [
	super initialize.
	sections := OrderedDictionary new.
]

{ #category : #'as yet unclassified' }
SLVMLirInstructionStream >> optimize [
	compilationTarget optimizeLirStream: self
]

{ #category : #'as yet unclassified' }
SLVMLirInstructionStream >> printOn: aStream [
	sections do: [ :section | section printOn: aStream ]
]

{ #category : #accessing }
SLVMLirInstructionStream >> sections [
	^ sections
]

{ #category : #'as yet unclassified' }
SLVMLirInstructionStream >> withSectionNamed: sectionName do: aBlock [
	| oldSection |
	oldSection := currentSection.
	self currentSectionNamed: sectionName.
	aBlock ensure: [ currentSection := oldSection ]
]

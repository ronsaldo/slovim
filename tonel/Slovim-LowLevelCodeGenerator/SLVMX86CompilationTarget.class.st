Class {
	#name : #SLVMX86CompilationTarget,
	#superclass : #SLVM32BitsPointerCompilationTarget,
	#classVars : [
		'R_386_32',
		'R_386_COPY',
		'R_386_GLOB_DAT',
		'R_386_GOT32',
		'R_386_GOTOFF',
		'R_386_GOTPC',
		'R_386_JMP_SLOT',
		'R_386_NONE',
		'R_386_PC32',
		'R_386_PLT32',
		'R_386_RELATIVE'
	],
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMX86CompilationTarget class >> initialize [
	super initialize.
	
	"A - addend"
	"B - base"
	"G - offset into the GOT"
	"GOT - GOT address"
	"L - linkage table offset"
	"P - place of relocation"
	"S - symbol value"
	R_386_NONE := 0. 	"None"
	R_386_32 := 1. 		"S + A"
	R_386_PC32 := 2.	"S + A - P"
	R_386_GOT32 := 3. 	"G + A - P"
	R_386_PLT32 := 4. 	"L + A - P"
	R_386_COPY := 5.	"None"
	R_386_GLOB_DAT := 6. 	"S"
	R_386_JMP_SLOT := 7. 	"S"
	R_386_RELATIVE := 8.	"B + A"
	R_386_GOTOFF := 9.	"S + A - GOT"
	R_386_GOTPC := 10. "GOT + A - P"
	
]

{ #category : #accessing }
SLVMX86CompilationTarget >> callingConventionDescriptionNamed: conventionName [
	#cdecl == conventionName ifTrue: [ ^ SLVMX86CDeclCallingConvention new ].
	#stdcall == conventionName ifTrue: [ ^ SLVMX86StdcallCallingConvention new ].
	#smalltalk == conventionName ifTrue: [ ^ SLVMX86SmalltalkCallingConvention new ].
	self error: 'Unsupported calling convention.'
]

{ #category : #'elf relocations' }
SLVMX86CompilationTarget >> convertRelocation: relocation section: section elfBuilder: elfBuilder [
	| table elfReloc symbolIndex |
	table := elfBuilder relocationSectionFor: section.
	elfReloc := table newEntry.
	symbolIndex := elfBuilder indexOfRelocationSymbol: relocation symbol section: (elfBuilder sectionFromContent: relocation section).
	elfReloc offset: relocation offset.
	relocation isAbsoluteOffset32 ifTrue: [
		^ elfReloc symbol: symbolIndex type: R_386_32
	].
	relocation isRelativeSOffset32 ifTrue: [
		^ elfReloc symbol: symbolIndex type: R_386_PC32
	].

	self error: 'Unsupported relocation type.'
]

{ #category : #'elf constants' }
SLVMX86CompilationTarget >> elfMachine [
	^ 3
]

{ #category : #'as yet unclassified' }
SLVMX86CompilationTarget >> generateMachineCodeFromInstructionStream: aStream [
	^ SLVMX86MachineCodeGenerator new generate: aStream
]

{ #category : #accessing }
SLVMX86CompilationTarget >> lowLevelCodeGeneratorClass [
	^ SLVMLirX86CodeGenerator
]

{ #category : #'as yet unclassified' }
SLVMX86CompilationTarget >> lowerLocalVariable: localVariable in: stackFrame [
	stackFrame frameLessMethod ifTrue: [ 
		^ ESP asX86Ptr + localVariable offset
	].

	^ EBP asX86Ptr + localVariable offset

]

{ #category : #'as yet unclassified' }
SLVMX86CompilationTarget >> lowerLocalVariables: stream [
	stream instructionsDo: [ :ins |
		ins isInstruction ifTrue: [ 
			ins operands doWithIndex: [ :op :index |
				op isStackFrameVariable ifTrue: [
					ins operands at: index put: EBP asX86Ptr + op offset
				]
			]
		]
	]

]

{ #category : #'as yet unclassified' }
SLVMX86CompilationTarget >> optimizeLirStream: stream [
	self
		removeExtraJmpFrom: stream
]

{ #category : #removing }
SLVMX86CompilationTarget >> removeExtraJmpFrom: stream [
	stream sections valuesDo: [ :section |
		section instructionsDo: [ :instruction |
			(instruction isInstruction and: [instruction opcode = JMP and: [ instruction operands first == instruction next ]]) ifTrue: [
				instruction removeFromStream
			]
		]
	]

]

{ #category : #accessing }
SLVMX86CompilationTarget >> usesElf64 [
	^ false
]

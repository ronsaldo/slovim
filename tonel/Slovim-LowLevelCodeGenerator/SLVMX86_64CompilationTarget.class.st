Class {
	#name : #'SLVMX86_64CompilationTarget',
	#superclass : #SLVM64BitsPointerCompilationTarget,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMX86_64CompilationTarget >> allocatableRegisters [
	^ {
	RDX . RBX. RSI . RDI . R8 . R9 . R10 . R11 . R12 . R13 . R14 . R15 .
	XMM0 . XMM1 . XMM2 . XMM3 . XMM4 . XMM5 . XMM6 . XMM7
	}
]

{ #category : #'elf constants' }
SLVMX86_64CompilationTarget >> elfMachine [
	^ 3
]

{ #category : #'as yet unclassified' }
SLVMX86_64CompilationTarget >> generateMachineCodeFromInstructionStream: aStream [
	^ SLVMX86MachineCodeGenerator new longMode: true; generate: aStream
]

{ #category : #accessing }
SLVMX86_64CompilationTarget >> lowLevelCodeGeneratorClass [
	^ SLVMLirX86FunctionCodeGenerator
]

{ #category : #'as yet unclassified' }
SLVMX86_64CompilationTarget >> lowerLocalVariable: localVariable in: stackFrame [
	stackFrame frameLessMethod ifTrue: [ 
		^ RSP asX86Ptr + localVariable offset
	].

	^ RBP asX86Ptr + localVariable offset

]

{ #category : #'as yet unclassified' }
SLVMX86_64CompilationTarget >> optimizeLirStream: stream [
	self
		removeExtraJmpFrom: stream
]

{ #category : #'as yet unclassified' }
SLVMX86_64CompilationTarget >> removeExtraJmpFrom: stream [
	stream sections valuesDo: [ :section |
		section instructionsDo: [ :instruction |
			(instruction isInstruction and: [instruction opcode = JMP and: [ instruction operands first == instruction next ]]) ifTrue: [
				instruction removeFromStream
			]
		]
	]

]

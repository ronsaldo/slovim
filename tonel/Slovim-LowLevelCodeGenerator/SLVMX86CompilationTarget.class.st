Class {
	#name : #SLVMX86CompilationTarget,
	#superclass : #SLVM32BitsPointerCompilationTarget,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMX86CompilationTarget >> allocatableRegisters [
	^ {
	EDX . EBX. ESI . EDI .
	XMM0 . XMM1 . XMM2 . XMM3 . XMM4 . XMM5 . XMM6 . XMM7
	}
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
	^ SLVMLirX86FunctionCodeGenerator
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

{ #category : #'as yet unclassified' }
SLVMX86CompilationTarget >> removeExtraJmpFrom: stream [
	stream sections valuesDo: [ :section |
		section instructionsDo: [ :instruction |
			(instruction isInstruction and: [instruction opcode = JMP and: [ instruction operands first == instruction next ]]) ifTrue: [
				instruction removeFromStream
			]
		]
	]

]

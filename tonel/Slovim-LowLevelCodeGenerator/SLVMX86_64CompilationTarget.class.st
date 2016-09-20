Class {
	#name : #'SLVMX86_64CompilationTarget',
	#superclass : #SLVM64BitsPointerCompilationTarget,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #accessing }
SLVMX86_64CompilationTarget >> callingConventionDescriptionNamed: conventionName [
	#cdecl == conventionName ifTrue: [ ^ SLVMX86_64CDeclCallingConvention new ].
	#stdcall == conventionName ifTrue: [ ^ SLVMX86_64CDeclCallingConvention new ].
	#smalltalk == conventionName ifTrue: [ ^ SLVMX86_64SmalltalkCallingConvention new ].
	self error: 'Unsupported calling convention.'
]

{ #category : #'elf constants' }
SLVMX86_64CompilationTarget >> elfMachine [
	^ 16r3E
]

{ #category : #'as yet unclassified' }
SLVMX86_64CompilationTarget >> generateMachineCodeFromInstructionStream: aStream [
	^ SLVMX86MachineCodeGenerator new longMode: true; generate: aStream
]

{ #category : #accessing }
SLVMX86_64CompilationTarget >> lowLevelCodeGeneratorClass [
	^ SLVMLirX86_64CodeGenerator
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

{ #category : #removing }
SLVMX86_64CompilationTarget >> removeExtraJmpFrom: stream [
	stream sections valuesDo: [ :section |
		section instructionsDo: [ :instruction |
			(instruction isInstruction and: [instruction opcode = JMP and: [ instruction operands first == instruction next ]]) ifTrue: [
				instruction removeFromStream
			]
		]
	]

]

{ #category : #accessing }
SLVMX86_64CompilationTarget >> usesElf64 [
	^ true
]

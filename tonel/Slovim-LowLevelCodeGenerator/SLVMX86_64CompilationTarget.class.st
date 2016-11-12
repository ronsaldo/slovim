Class {
	#name : #'SLVMX86_64CompilationTarget',
	#superclass : #SLVM64BitsPointerCompilationTarget,
	#classVars : [
		'R_X86_64_16',
		'R_X86_64_32',
		'R_X86_64_32S',
		'R_X86_64_64',
		'R_X86_64_8',
		'R_X86_64_COPY',
		'R_X86_64_DTPMOD64',
		'R_X86_64_DTPOFF32',
		'R_X86_64_DTPOFF64',
		'R_X86_64_GLOB_DAT',
		'R_X86_64_GOT32',
		'R_X86_64_GOTOFF64',
		'R_X86_64_GOTPC32',
		'R_X86_64_GOTPC32_TLSDESC',
		'R_X86_64_GOTPCREL',
		'R_X86_64_GOTTPOFF',
		'R_X86_64_IRELATIVE',
		'R_X86_64_JUMP_SLOT',
		'R_X86_64_NONE',
		'R_X86_64_PC16',
		'R_X86_64_PC32',
		'R_X86_64_PC64',
		'R_X86_64_PC8',
		'R_X86_64_PLT32',
		'R_X86_64_RELATIVE',
		'R_X86_64_SIZE32',
		'R_X86_64_SIZE64',
		'R_X86_64_TLSDESC',
		'R_X86_64_TLSDESC_CALL',
		'R_X86_64_TLSGD',
		'R_X86_64_TLSLD',
		'R_X86_64_TPOFF32',
		'R_X86_64_TPOFF64'
	],
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMX86_64CompilationTarget class >> initialize [
	super initialize.
	
	self initializeElfRelocations.
]

{ #category : #'as yet unclassified' }
SLVMX86_64CompilationTarget class >> initializeElfRelocations [

	R_X86_64_NONE := 0.
	R_X86_64_64 := 1.
	R_X86_64_PC32 := 2.
	R_X86_64_GOT32 := 3.
	R_X86_64_PLT32 := 4.
	R_X86_64_COPY := 5.
	R_X86_64_GLOB_DAT := 6.
	R_X86_64_JUMP_SLOT := 7.
	R_X86_64_RELATIVE := 8.
	R_X86_64_GOTPCREL := 9.
	R_X86_64_32 := 10.
	R_X86_64_32S := 11.
	R_X86_64_16 := 12.
	R_X86_64_PC16 := 13.
	R_X86_64_8 := 14.
	R_X86_64_PC8 := 15.
	R_X86_64_DTPMOD64 := 16.
	R_X86_64_DTPOFF64 := 17.
	R_X86_64_TPOFF64 := 18.
	R_X86_64_TLSGD := 19.
	R_X86_64_TLSLD := 20.
	R_X86_64_DTPOFF32 := 21.
	R_X86_64_GOTTPOFF := 22.
	R_X86_64_TPOFF32 := 23.
	R_X86_64_PC64 := 24.
	R_X86_64_GOTOFF64 := 25.
	R_X86_64_GOTPC32 := 26.
	R_X86_64_SIZE32 := 32.
	R_X86_64_SIZE64 := 33.
	R_X86_64_GOTPC32_TLSDESC := 34.
	R_X86_64_TLSDESC_CALL := 35.
	R_X86_64_TLSDESC := 36.
	R_X86_64_IRELATIVE := 37.
]

{ #category : #accessing }
SLVMX86_64CompilationTarget >> callingConventionDescriptionNamed: conventionName [
	#cdecl == conventionName ifTrue: [ ^ SLVMX86_64CDeclCallingConvention new ].
	#stdcall == conventionName ifTrue: [ ^ SLVMX86_64CDeclCallingConvention new ].
	#smalltalk == conventionName ifTrue: [ ^ SLVMX86_64SmalltalkCallingConvention new ].
	self error: 'Unsupported calling convention.'
]

{ #category : #accessing }
SLVMX86_64CompilationTarget >> canonicalName [
	^ #amd64
]

{ #category : #'as yet unclassified' }
SLVMX86_64CompilationTarget >> convertRelocation: relocation section: section elfBuilder: elfBuilder [
	| table elfReloc symbolIndex |
	table := elfBuilder relocationWithAddendSectionFor: section.
	relocation clearImplicitAddendIn: section.
	
	elfReloc := table newEntry.
	symbolIndex := elfBuilder indexOfRelocationSymbol: relocation symbol section: (elfBuilder sectionFromContent: relocation section).
	elfReloc
		offset: relocation offset;
		addend: relocation addend.
	relocation isAbsoluteOffset32 ifTrue: [
		^ elfReloc symbol: symbolIndex type: R_X86_64_32
	].
	relocation isRelativeSOffset32 ifTrue: [
		^ elfReloc symbol: symbolIndex type: R_X86_64_PC32
	].
	relocation isAbsoluteOffset64 ifTrue: [
		^ elfReloc symbol: symbolIndex type: R_X86_64_64
	].
	relocation isRelativeSOffset64 ifTrue: [
		^ elfReloc symbol: symbolIndex type: R_X86_64_PC64
	].
	self halt.
	

]

{ #category : #'elf constants' }
SLVMX86_64CompilationTarget >> elfMachine [
	^ 16r3E
]

{ #category : #constructors }
SLVMX86_64CompilationTarget >> emitTo: instructionStream registrationOfObjectSection: sectionLabel size: sectionSize package: packageRegistration [
	| registrationInformationLabel registerLabel unregisterLabel registrationSymbol unregistrationSymbol oopSectionMetaData sectionFlags cdeclConvention argumentRegisters |
	cdeclConvention := self callingConventionDescriptionNamed: #cdecl.
	argumentRegisters := cdeclConvention integerArgumentRegisters.
	
	instructionStream withSectionNamed: #'.data' do: [
		registrationInformationLabel := SLVMLirLabel new name: #'_OopRegistrationInformation'.
		oopSectionMetaData := ByteArray streamContents: [ :out |
			sectionFlags := 3.
			packageRegistration ifNotNil: [ sectionFlags := sectionFlags + 4 ].
			
			self ulong
				encodeConstant: 0 bigEndian: false intoByteStream: out;
				encodeConstant: 0 bigEndian: false intoByteStream: out;
				encodeConstant: sectionSize bigEndian: false intoByteStream: out;
				encodeConstant: sectionFlags bigEndian: false intoByteStream: out.
		].
	
		instructionStream
			add: registrationInformationLabel;
			add: (SLVMLirBlob new content: oopSectionMetaData);
			add: (SLVMLirLabelValue new
				label: sectionLabel;
				size: 8;
				labelOffset: 0;
				yourself).
				
		packageRegistration ifNotNil: [ 
			"Emit the package registration function pointer."
			instructionStream add: (SLVMLirLabelValue new
				label: packageRegistration;
				size: 8;
				labelOffset: 0;
				yourself).
		].
	].

	instructionStream withSectionNamed: #'.oopRegistration' do: [
		registerLabel := SLVMLirLabel new name: #'registerOopSection'.
		unregisterLabel := SLVMLirLabel new name: #'unregisterOopSection'.
		registrationSymbol := SLVMLirExternalLabel new
			name: #'slvm_dynrun_registerStaticHeap';
			public;
			yourself.
		unregistrationSymbol := SLVMLirExternalLabel new
			name: #'slvm_dynrun_unregisterStaticHeap';
			public;
			yourself.
		instructionStream
			add: registerLabel;
			addX86: PUSH with: RBP;
			addX86: MOV with: RBP with: RSP;
			
			addX86: MOV with: argumentRegisters first with: registrationInformationLabel;
			addX86: CALL with: registrationSymbol;
			
			addX86: MOV with: RSP with: RBP;
			addX86: POP with: RBP;
			addX86: RET;
			
			add: unregisterLabel;
			addX86: PUSH with: RBP;
			addX86: MOV with: RBP with: RSP;
			
			addX86: MOV with: argumentRegisters first with: registrationInformationLabel;
			addX86: CALL with: unregistrationSymbol;
			
			addX86: MOV with: RSP with: RBP;
			addX86: POP with: RBP;
			addX86: RET
	].

	instructionStream withSectionNamed: #'.ctors' do: [
		instructionStream add: (SLVMLirLabelValue new
			label: registerLabel;
			size: 8;
			labelOffset: 0;
			yourself
		)
	].

	instructionStream withSectionNamed: #'.dtors' do: [
		instructionStream add: (SLVMLirLabelValue new
			label: unregisterLabel;
			size: 8;
			labelOffset: 0;
			yourself
		)
	].

]

{ #category : #accessing }
SLVMX86_64CompilationTarget >> framePointer [
	^ RBP
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
SLVMX86_64CompilationTarget >> stackPointer [
	^ RSP
]

{ #category : #accessing }
SLVMX86_64CompilationTarget >> usesElf64 [
	^ true
]

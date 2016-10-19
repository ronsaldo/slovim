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

{ #category : #'as yet unclassified' }
SLVMX86_64CompilationTarget >> convertRelocation: relocation section: section elfBuilder: builder [
	self flag: 'ToDo'
]

{ #category : #'elf constants' }
SLVMX86_64CompilationTarget >> elfMachine [
	^ 16r3E
]

{ #category : #constructors }
SLVMX86_64CompilationTarget >> emitTo: instructionStream registrationOfObjectSection: sectionLabel size: sectionSize package: packageRegistration [
	| registrationInformationLabel registerLabel unregisterLabel registrationSymbol unregistrationSymbol oopSectionMetaData sectionFlags |
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
			addX86: PUSH with: registrationInformationLabel;
			addX86: CALL with: registrationSymbol;
			addX86: ADD with: RSP with: 8;
			addX86: RET;
			
			add: unregisterLabel;
			addX86: PUSH with: registrationInformationLabel;
			addX86: CALL with: unregistrationSymbol;
			addX86: ADD with: RSP with: 8;
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

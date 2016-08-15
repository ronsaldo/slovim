Class {
	#name : #SLVMLirX86Constants,
	#superclass : #SharedPool,
	#classVars : [
		'ADC',
		'ADD',
		'ADDPD',
		'ADDPS',
		'ADDSS',
		'ADDSUBPD',
		'ADDSUBPS',
		'AH',
		'AL',
		'AND',
		'ANDN',
		'ANDNPD',
		'ANDNPS',
		'ANDPD',
		'ANDPS',
		'AX',
		'BH',
		'BL',
		'BP',
		'BX',
		'CALL',
		'CH',
		'CL',
		'CLAC',
		'CLC',
		'CLD',
		'CLI',
		'CMP',
		'CMPPD',
		'CMPPS',
		'CMPSD',
		'CMPSS',
		'CMPXCHG',
		'CX',
		'DEC',
		'DH',
		'DI',
		'DIV',
		'DIVPD',
		'DIVPS',
		'DIVSS',
		'DL',
		'DPPD',
		'DPPS',
		'DX',
		'EAX',
		'EBP',
		'EBX',
		'ECX',
		'EDI',
		'EDX',
		'EMMS',
		'ENTER',
		'ESI',
		'ESP',
		'FDECSTP',
		'FILD',
		'FLD',
		'FST',
		'FSTP',
		'HLT',
		'HSUBPD',
		'HSUBPS',
		'IDIV',
		'IMUL',
		'IN',
		'INC',
		'INT',
		'IRET',
		'InstructionOpcodeGeneratorMap',
		'InstructionOpcodeMnemonicMap',
		'JA',
		'JAE',
		'JB',
		'JBE',
		'JC',
		'JCXZ',
		'JE',
		'JECXZ',
		'JG',
		'JGE',
		'JL',
		'JLE',
		'JMP',
		'JNA',
		'JNAE',
		'JNB',
		'JNBE',
		'JNC',
		'JNE',
		'JNG',
		'JNGE',
		'JNL',
		'JNLE',
		'JNO',
		'JNP',
		'JNS',
		'JNZ',
		'JO',
		'JP',
		'JPE',
		'JPO',
		'JRCXZ',
		'JS',
		'JZ',
		'LEA',
		'LEAVE',
		'LFENCE',
		'LGDT',
		'LIDT',
		'LMSW',
		'LOCK',
		'LTR',
		'MFENCE',
		'MM0',
		'MM1',
		'MM2',
		'MM3',
		'MM4',
		'MM5',
		'MM6',
		'MM7',
		'MOV',
		'NEG',
		'NOP',
		'OR',
		'OUT',
		'POP',
		'POPA',
		'POPF',
		'PUSH',
		'PUSHA',
		'PUSHF',
		'R10',
		'R11',
		'R12',
		'R13',
		'R14',
		'R15',
		'R8',
		'R9',
		'RAX',
		'RBP',
		'RBX',
		'RCL',
		'RCR',
		'RCX',
		'RDI',
		'RDMSR',
		'RDPID',
		'RDTSC',
		'RDTSCP',
		'RDX',
		'REP',
		'REPE',
		'REPNE',
		'REPNZ',
		'REPZ',
		'RET',
		'ROL',
		'ROR',
		'RORX',
		'RSI',
		'RSP',
		'SAHF',
		'SAL',
		'SALX',
		'SAR',
		'SARX',
		'SBB',
		'SFENCE',
		'SGDT',
		'SHL',
		'SHLD',
		'SHLX',
		'SHR',
		'SHRD',
		'SHRX',
		'SI',
		'SIDT',
		'SLDT',
		'SMSW',
		'SP',
		'STAC',
		'STC',
		'STD',
		'STI',
		'SUB',
		'SYSCALL',
		'SYSENTER',
		'SYSEXIT',
		'SYSRET',
		'TEST',
		'TZCNT',
		'UD2',
		'WAIT',
		'WRMSR',
		'XADD',
		'XCHG',
		'XMM0',
		'XMM1',
		'XMM10',
		'XMM11',
		'XMM12',
		'XMM13',
		'XMM14',
		'XMM15',
		'XMM2',
		'XMM3',
		'XMM4',
		'XMM5',
		'XMM6',
		'XMM7',
		'XMM8',
		'XMM9',
		'XOR'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #initialization }
SLVMLirX86Constants class >> declareRegisters: registerNames withClass: registerClass [
	registerNames doWithIndex: [ :mnemonic :index |
		(self hasClassVarNamed: mnemonic) ifFalse: [ 
			self addClassVarNamed: mnemonic.
		].
		self classVarNamed: mnemonic put: (registerClass new name: mnemonic; value: index - 1)
	].
]

{ #category : #initialization }
SLVMLirX86Constants class >> initialize [
	super initialize.
	
	self initializeRegisters.	
	self initializeMnemonics.	
	
]

{ #category : #initialization }
SLVMLirX86Constants class >> initializeMnemonics [
	InstructionOpcodeMnemonicMap := Dictionary new.
	InstructionOpcodeGeneratorMap := Dictionary new.
	
	#(
	ADC
	ADD
	ADDPD
	ADDPS
	ADDSS
	ADDSUBPD
	ADDSUBPS
	AND
	ANDN
	ANDPD
	ANDPS
	ANDNPD
	ANDNPS
	CALL
	CLAC
	CLC
	CLD
	CLI
	CMP
	CMPPD
	CMPPS
	CMPSD
	CMPSS
	CMPXCHG
	DEC
	DIV
	DIVPD
	DIVPS
	DIVSS
	DPPD
	DPPS
	EMMS
	ENTER
	FDECSTP
	FILD
	FLD
	FST
	FSTP
	HLT
	HSUBPD
	HSUBPS
	IDIV
	IMUL
	IN
	INC
	INT
	IRET
	JA JAE JB JBE JC JCXZ JECXZ JRCXZ JE JG JGE JL JLE JNA JNAE JNB JNBE
	JNC JNE JNG JNGE JNL JNLE JNO JNP JNS JNZ JO JP JPE JPO JS JZ
	JMP
	LEA
	LEAVE
	LFENCE
	LGDT
	LIDT
	LMSW
	LOCK
	LTR
	MFENCE
	MOV
	NEG
	NOP
	OR
	OUT
	POP
	POPA
	POPF
	PUSH
	PUSHA
	PUSHF
	RCL RCR ROL ROR
	RDMSR
	RDPID
	RDTSC
	RDTSCP
	REP REPE REPZ REPNE REPNZ
	RET
	RORX
	SAHF
	SAL SAR SHL SHR
	SALX SARX SHLX SHRX
	SBB
	SFENCE
	SGDT
	SHLD SHRD
	SIDT
	SLDT
	SMSW
	STAC
	STC
	STD
	STI
	SUB
	SYSCALL
	SYSENTER
	SYSEXIT
	SYSRET
	TEST
	TZCNT
	UD2
	WAIT
	WRMSR
	XADD
	XCHG
	XOR
	
	) doWithIndex: [ :mnemonic :index |
		(self hasClassVarNamed: mnemonic) ifFalse: [ 
			self addClassVarNamed: mnemonic.
		].
		self classVarNamed: mnemonic put: index.
		InstructionOpcodeMnemonicMap at: index put: mnemonic.
		InstructionOpcodeGeneratorMap at: index put: ('generate' , mnemonic , ':') asSymbol
	].

]

{ #category : #initialization }
SLVMLirX86Constants class >> initializeRegisters [
	self
		declareRegisters: #(AL CL DL BL AH CH DH BH)
		withClass: SLVMLirX86RegisterInt8.
	self
		declareRegisters: #(AX CX DX BX SP BP SI DI)
		withClass: SLVMLirX86RegisterInt16.

	self
		declareRegisters: #(EAX ECX EDX EBX ESP EBP ESI EDI)
		withClass: SLVMLirX86RegisterInt32.

	self
		declareRegisters: #(RAX RCX RDX RBX RSP RBP RSI RDI R8 R9 R10 R11 R12 R13 R14 R15)
		withClass: SLVMLirX86RegisterInt64.

	self
		declareRegisters: #(MM0 MM1 MM2 MM3 MM4 MM5 MM6 MM7)
		withClass: SLVMLirX86RegisterVectorMMX.

	self
		declareRegisters: #(XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
			XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15)
		withClass: SLVMLirX86RegisterVector.
]

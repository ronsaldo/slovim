Class {
	#name : #LLVMInstruction,
	#superclass : #LLVMUser,
	#instVars : [
		'parent',
		'metadata'
	],
	#classVars : [
		'AtomicOrderingMap'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'class initialization' }
LLVMInstruction class >> initialize [
	AtomicOrderingMap := Dictionary newFromPairs: {
		#unordered . LLVMAtomicOrderingUnordered.
		#monotonic . LLVMAtomicOrderingMonotonic.
		#acquire . LLVMAtomicOrderingAcquire.
		#release . LLVMAtomicOrderingRelease.
		#acq_rel . LLVMAtomicOrderingAcquireRelease.
		#seq_cst . LLVMAtomicOrderingSequentiallyConsistent
	}	
]

{ #category : #adding }
LLVMInstruction >> addDebugMetadata: metadataValue [
	^ self addNamed: #dbg metadata: metadataValue
]

{ #category : #adding }
LLVMInstruction >> addNamed: metadataName metadata: metadataValue [
	metadata := metadata copyWith: { metadataName . metadataValue}.
	^ metadataValue
]

{ #category : #accessing }
LLVMInstruction >> buildHandle [
	self shouldNotImplement
]

{ #category : #'as yet unclassified' }
LLVMInstruction >> buildHandleWithBuilder: aBuilder [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
LLVMInstruction >> fixupInstructionHandle [
	"An opportunity for performing required fixups after the instructions are created"
]

{ #category : #printing }
LLVMInstruction >> fullPrintOn: aStream [
	type isVoidTy ifFalse: [
		aStream print: self.
		aStream << ' = '.
	].
	aStream nextPutAll: self mnemonic.
	self printParametersOn: aStream.
	self printMetadataOn: aStream
]

{ #category : #initialization }
LLVMInstruction >> initialize [
	super initialize.
	metadata := #().
	
]

{ #category : #testing }
LLVMInstruction >> isInstruction [
	^ true
]

{ #category : #printing }
LLVMInstruction >> mnemonic [
	self subclassResponsibility
]

{ #category : #accessing }
LLVMInstruction >> parent [
	^ parent
]

{ #category : #accessing }
LLVMInstruction >> parent: anObject [
	parent := anObject
]

{ #category : #printing }
LLVMInstruction >> printMetadataOn: aStream [
	| metadataName metadataValue |
	metadata do: [ :metadataNamePair |
		metadataName := metadataNamePair first.
		metadataValue := metadataNamePair second.
		aStream nextPutAll: ', !'; nextPutAll: metadataName; space; print: metadataValue
	]
]

{ #category : #printing }
LLVMInstruction >> printParametersOn: aStream [
	self subclassResponsibility
	
]

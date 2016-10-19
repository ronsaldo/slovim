Class {
	#name : #'SLVMX86_64SmalltalkCallingConvention',
	#superclass : #'SLVMX86_64CallingConvention',
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMX86_64SmalltalkCallingConvention >> calledRegisters [
	^ { RAX . RCX . RDX . RBX. RSI . RDI . R8 . R9 . R10 . R11 . R12 . R13 . R14 . R15 .
	XMM0 . XMM1 . XMM2 . XMM3 . XMM4 . XMM5 . XMM6 . XMM7 .
	XMM8 . XMM9 . XMM10 . XMM11 . XMM11 . XMM11 . XMM11 . XMM11
	}
]

{ #category : #'as yet unclassified' }
SLVMX86_64SmalltalkCallingConvention >> callerRegisters [
	^ { }
]

{ #category : #accessing }
SLVMX86_64SmalltalkCallingConvention >> hasContextMetadata [
	^ true
]

{ #category : #accessing }
SLVMX86_64SmalltalkCallingConvention >> hasSegmentedStack [
	^ true
]

{ #category : #accessing }
SLVMX86_64SmalltalkCallingConvention >> isStackCleanedByCaller [
	^ false
]

Class {
	#name : #'SLVMX86_64CallingConvention',
	#superclass : #SLVMCallingConvention,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #accessing }
SLVMX86_64CallingConvention >> calledRegisters [
	^ { RAX . RCX . RDX . RSI . RDI . R8 . R9 . R10 . R11 .
	XMM0 . XMM1 . XMM2 . XMM3 . XMM4 . XMM5 . XMM6 . XMM7 .
	XMM8 . XMM9 . XMM10 . XMM11 . XMM11 . XMM11 . XMM11 . XMM11
	}
]

{ #category : #accessing }
SLVMX86_64CallingConvention >> callerRegisters [
	^ { RBX . R12 . R13 . R14 . R15 }
]

{ #category : #accessing }
SLVMX86_64CallingConvention >> canBeFrameLess [
	^ true
]

{ #category : #accessing }
SLVMX86_64CallingConvention >> floatReturnRegister [
	^ XMM0
]

{ #category : #accessing }
SLVMX86_64CallingConvention >> hasContextMetadata [
	^ false
]

{ #category : #accessing }
SLVMX86_64CallingConvention >> intResultRegister [
	^ RAX
]

{ #category : #accessing }
SLVMX86_64CallingConvention >> isStackCleanedByCaller [
	^ true
]

{ #category : #accessing }
SLVMX86_64CallingConvention >> scratchRegisters [
	^ {
	RAX . RCX .
	XMM0 . XMM1 .
	}
]

{ #category : #accessing }
SLVMX86_64CallingConvention >> secondIntResultRegister [
	^ RCX
]

{ #category : #accessing }
SLVMX86_64CallingConvention >> sendDescriptionRegister [
	^ RCX
]

{ #category : #accessing }
SLVMX86_64CallingConvention >> sendSelectorRegister [
	^ RAX
]

{ #category : #accessing }
SLVMX86_64CallingConvention >> stackAlignment [
	^ 16
]

{ #category : #accessing }
SLVMX86_64CallingConvention >> usableRegisters [
	^ {
	RAX . RCX . RDX . RBX. RSI . RDI . R8 . R9 . R10 . R11 . R12 . R13 . R14 . R15 .
	XMM0 . XMM1 . XMM2 . XMM3 . XMM4 . XMM5 . XMM6 . XMM7 .
	XMM8 . XMM9 . XMM10 . XMM11 . XMM12 . XMM13 . XMM14 . XMM15 .
	}
]

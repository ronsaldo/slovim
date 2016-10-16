"
IA32 calling conventions
"
Class {
	#name : #SLVMX86CallingConvention,
	#superclass : #SLVMCallingConvention,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #accessing }
SLVMX86CallingConvention >> calledRegisters [
	^ { EAX . ECX . EDX .
	XMM0 . XMM1 . XMM2 . XMM3 . XMM4 . XMM5 . XMM6 . XMM7
	}
]

{ #category : #accessing }
SLVMX86CallingConvention >> callerRegisters [
	^ { EBX . EDI . ESI }
]

{ #category : #accessing }
SLVMX86CallingConvention >> canBeFrameLess [
	^ true
]

{ #category : #accessing }
SLVMX86CallingConvention >> floatReturnRegister [
	^ nil
]

{ #category : #accessing }
SLVMX86CallingConvention >> gotRegister [
	^ EBX
]

{ #category : #accessing }
SLVMX86CallingConvention >> hasContextMetadata [
	^ false
]

{ #category : #accessing }
SLVMX86CallingConvention >> intResultRegister [
	^ EAX
]

{ #category : #accessing }
SLVMX86CallingConvention >> isStackCleanedByCaller [
	^ true
]

{ #category : #accessing }
SLVMX86CallingConvention >> receiverRegister [
	^ nil
]

{ #category : #accessing }
SLVMX86CallingConvention >> scratchRegisters [
	^ {
	EAX . ECX .
	XMM0 . XMM1 .
	}
]

{ #category : #accessing }
SLVMX86CallingConvention >> secondIntResultRegister [
	^ ECX
]

{ #category : #'as yet unclassified' }
SLVMX86CallingConvention >> sendDescriptionRegister [
	^ ECX
]

{ #category : #'as yet unclassified' }
SLVMX86CallingConvention >> sendSelectorRegister [
	^ EAX
]

{ #category : #accessing }
SLVMX86CallingConvention >> stackAlignment [
	^ 16
]

{ #category : #accessing }
SLVMX86CallingConvention >> usableRegisters [
	^ {
	EAX . ECX . EDX . EBX . ESI . EDI .
	XMM0 . XMM1 . XMM2 . XMM3 . XMM4 . XMM5 . XMM6 . XMM7
	}
]

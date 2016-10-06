Class {
	#name : #SLVMX86SmalltalkCallingConvention,
	#superclass : #SLVMX86CallingConvention,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #accessing }
SLVMX86SmalltalkCallingConvention >> calledRegisters [
	^ { EAX . ECX . EDX . EBX . EDI . ESI .
	XMM0 . XMM1 . XMM2 . XMM3 . XMM4 . XMM5 . XMM6 . XMM7
	}
]

{ #category : #accessing }
SLVMX86SmalltalkCallingConvention >> callerRegisters [
	^ { }
]

{ #category : #accessing }
SLVMX86SmalltalkCallingConvention >> floatReturnRegister [
	^ XMM0
]

{ #category : #accessing }
SLVMX86SmalltalkCallingConvention >> hasContextMetadata [
	^ true
]

{ #category : #accessing }
SLVMX86SmalltalkCallingConvention >> isStackCleanedByCaller [
	^ false
]

{ #category : #accessing }
SLVMX86SmalltalkCallingConvention >> receiverRegister [
	^ EAX
]

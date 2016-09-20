Class {
	#name : #SLVMX86SmalltalkCallingConvention,
	#superclass : #SLVMX86CallingConvention,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #accessing }
SLVMX86SmalltalkCallingConvention >> floatReturnRegister [
	^ XMM0
]

{ #category : #accessing }
SLVMX86SmalltalkCallingConvention >> isStackCleanedByCaller [
	^ false
]

{ #category : #accessing }
SLVMX86SmalltalkCallingConvention >> receiverRegister [
	^ EAX
]

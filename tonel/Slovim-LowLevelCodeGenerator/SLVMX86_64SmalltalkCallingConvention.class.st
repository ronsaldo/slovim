Class {
	#name : #'SLVMX86_64SmalltalkCallingConvention',
	#superclass : #'SLVMX86_64CallingConvention',
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMX86_64SmalltalkCallingConvention >> hasContextMetadata [
	^ true
]

{ #category : #accessing }
SLVMX86_64SmalltalkCallingConvention >> isStackCleanedByCaller [
	^ false
]

{ #category : #accessing }
SLVMX86_64SmalltalkCallingConvention >> receiverRegister [
	^ RAX
]

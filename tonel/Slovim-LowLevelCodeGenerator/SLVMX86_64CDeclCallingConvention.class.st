Class {
	#name : #'SLVMX86_64CDeclCallingConvention',
	#superclass : #'SLVMX86_64CallingConvention',
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMX86_64CDeclCallingConvention >> floatArgumentRegisters [
	^ { XMM0 . XMM1 . XMM2 . XMM3 . XMM4 . XMM5 . XMM6 }
]

{ #category : #'as yet unclassified' }
SLVMX86_64CDeclCallingConvention >> integerArgumentRegisters [
	^ { RDI . RSI . RDX . RCX . R8 . R9 }
]

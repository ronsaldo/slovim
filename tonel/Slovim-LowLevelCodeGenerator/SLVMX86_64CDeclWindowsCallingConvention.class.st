Class {
	#name : #'SLVMX86_64CDeclWindowsCallingConvention',
	#superclass : #'SLVMX86_64CDeclCallingConvention',
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMX86_64CDeclWindowsCallingConvention >> floatArgumentRegisters [
	^ { XMM0 . XMM1 . XMM2 . XMM3 }
]

{ #category : #'as yet unclassified' }
SLVMX86_64CDeclWindowsCallingConvention >> integerArgumentRegisters [
	^ { RCX . RDX . R8 . R9 }
]

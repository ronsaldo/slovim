Class {
	#name : #SLVMX86StdcallCallingConvention,
	#superclass : #SLVMX86CallingConvention,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #accessing }
SLVMX86StdcallCallingConvention >> isStackCleanedByCaller [
	^ false
]

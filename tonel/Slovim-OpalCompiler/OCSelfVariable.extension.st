Extension { #name : #OCSelfVariable }

{ #category : #'*Slovim-OpalCompiler' }
OCSelfVariable >> emitSLVMValue: builder scope: slvmScope [
	^ slvmScope selfValue
]

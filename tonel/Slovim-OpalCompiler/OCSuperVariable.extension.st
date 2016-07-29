Extension { #name : #OCSuperVariable }

{ #category : #'*Slovim-OpalCompiler' }
OCSuperVariable >> emitSLVMValue: builder scope: slvmScope [
	^ slvmScope selfValue
]

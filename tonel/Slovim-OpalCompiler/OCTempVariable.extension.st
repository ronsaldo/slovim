Extension { #name : #OCTempVariable }

{ #category : #'*Slovim-OpalCompiler' }
OCTempVariable >> emitSLVM: builder store: value scope: slvmScope [
	^ builder store: value in: (slvmScope lookSymbol: name recursivelyWith: builder)
]

{ #category : #'*Slovim-OpalCompiler' }
OCTempVariable >> emitSLVMValue: builder scope: slvmScope [
	^ builder load: (slvmScope lookSymbol: name recursivelyWith: builder)
]

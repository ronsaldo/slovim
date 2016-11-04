Extension { #name : #OCTempVariable }

{ #category : #'*Slovim-OpalCompiler' }
OCTempVariable >> emitSLVM: builder store: value scope: slvmScope [
	^ builder store: value in: (slvmScope lookSymbolRecursively: name withBuilder: builder)
]

{ #category : #'*Slovim-OpalCompiler' }
OCTempVariable >> emitSLVMValue: builder scope: slvmScope [
	^ builder load: (slvmScope lookSymbolRecursively: name withBuilder: builder)
]

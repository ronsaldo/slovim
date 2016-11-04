Extension { #name : #OCArgumentVariable }

{ #category : #'*Slovim-OpalCompiler' }
OCArgumentVariable >> emitSLVMValue: builder scope: slvmScope [
	^ slvmScope lookSymbolRecursively: name withBuilder: builder
]

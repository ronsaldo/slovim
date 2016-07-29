Extension { #name : #OCArgumentVariable }

{ #category : #'*Slovim-OpalCompiler' }
OCArgumentVariable >> emitSLVMValue: builder scope: slvmScope [
	^ slvmScope lookSymbol: name recursivelyWith: builder
]

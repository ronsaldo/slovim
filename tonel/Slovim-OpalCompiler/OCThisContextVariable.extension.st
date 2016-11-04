Extension { #name : #OCThisContextVariable }

{ #category : #'*Slovim-OpalCompiler' }
OCThisContextVariable >> emitSLVMValue: builder scope: slvmScope [
	^ slvmScope emitThisContext: builder
]

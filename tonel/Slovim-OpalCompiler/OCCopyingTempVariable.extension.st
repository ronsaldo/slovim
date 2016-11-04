Extension { #name : #OCCopyingTempVariable }

{ #category : #'*Slovim-OpalCompiler' }
OCCopyingTempVariable >> emitSLVM: builder store: value scope: slvmScope [
	^ originalVar emitSLVM: builder store: value scope: slvmScope
]

{ #category : #'*Slovim-OpalCompiler' }
OCCopyingTempVariable >> emitSLVMValue: builder scope: slvmScope [
	^ originalVar emitSLVMValue: builder scope: slvmScope
]

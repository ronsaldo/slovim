Extension { #name : #OCSlotVariable }

{ #category : #'*Slovim-OpalCompiler' }
OCSlotVariable >> emitSLVM: builder store: value scope: slvmScope [
	^ slot emitSLVM: builder store: value scope: slvmScope
]

{ #category : #'*Slovim-OpalCompiler' }
OCSlotVariable >> emitSLVMValue: builder scope: slvmScope [
	^ slot emitSLVMValue: builder scope: slvmScope
]

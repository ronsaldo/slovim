Extension { #name : #OCAbstractVariable }

{ #category : #'*Slovim-OpalCompiler' }
OCAbstractVariable >> emitSLVM: builder store: value scope: slvmScope [
	self subclassResponsibility
]

{ #category : #'*Slovim-OpalCompiler' }
OCAbstractVariable >> emitSLVMValue: builder scope: slvmScope [
	self subclassResponsibility
]

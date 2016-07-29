Extension { #name : #Slot }

{ #category : #'*Slovim-OpalCompiler' }
Slot >> emitSLVM: builder store: value scope: slvmScope [
	self subclassResponsibility
]

{ #category : #'*Slovim-OpalCompiler' }
Slot >> emitSLVMValue: builder scope: slvmScope [
	self subclassResponsibility
]

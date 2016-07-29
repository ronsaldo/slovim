Extension { #name : #InstanceVariableSlot }

{ #category : #'*Slovim-OpalCompiler' }
InstanceVariableSlot >> emitSLVM: builder store: value scope: slvmScope [
	^ builder store: value in: (builder getReference: slvmScope selfValue element: (SLVMConstantValue int: index - 1))
]

{ #category : #'*Slovim-OpalCompiler' }
InstanceVariableSlot >> emitSLVMValue: builder scope: slvmScope [
	^ builder load: (builder getReference: slvmScope selfValue element: (SLVMConstantValue int: index - 1))
]

Extension { #name : #SLVMConstantValue }

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMConstantValue >> asLirInstructionOperand [
	^ SLVMLirImmediate new value: self value
]

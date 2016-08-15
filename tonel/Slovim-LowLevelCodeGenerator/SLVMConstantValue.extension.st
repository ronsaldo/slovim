Extension { #name : #SLVMConstantValue }

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMConstantValue >> asLirBlob [
	^ SLVMLirBlob content: self asBlob
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMConstantValue >> asLirInstructionOperand [
	^ SLVMLirImmediate new value: self value
]

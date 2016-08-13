Extension { #name : #Integer }

{ #category : #'*Slovim-LowLevelCodeGenerator' }
Integer >> asLirInstructionOperand [
	^ SLVMLirImmediate new value: self
]

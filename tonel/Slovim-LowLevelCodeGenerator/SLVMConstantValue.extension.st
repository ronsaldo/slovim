Extension { #name : #SLVMConstantValue }

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMConstantValue >> asLirBlob [
	^ SLVMLirBlob content: self asBlob
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMConstantValue >> asLirInstructionOperand [
	^ SLVMLirImmediate new value: self value
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMConstantValue >> writeToLirBlock: constantBlock withLabel: label withGenerator: generator [
	| blob |
	blob := self asLirBlob.
	label contentSize: blob content size.
	constantBlock
		addInstruction: blob.
]

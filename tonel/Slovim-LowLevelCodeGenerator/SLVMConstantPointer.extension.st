Extension { #name : #SLVMConstantPointer }

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMConstantPointer >> writeToLirBlock: constantBlock withLabel: label withGenerator: generator [
	label contentSize: type size.
	constantBlock
		addInstruction: (SLVMLirLabelValue new
			label: label;
			size: type size;
			yourself
		).
]

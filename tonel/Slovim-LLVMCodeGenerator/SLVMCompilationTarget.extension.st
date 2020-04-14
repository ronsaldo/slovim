Extension { #name : #SLVMCompilationTarget }

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_x86 [
	^ SLVMLLVMCompilationTarget x86
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_x86_64 [
	^ SLVMLLVMCompilationTarget x86_64
]

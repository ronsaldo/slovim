Extension { #name : #SLVMCompilationTarget }

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_webAssembly [
	^ SLVMLLVMCompilationTarget webAssembly
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_webAssembly32 [
	^ SLVMLLVMCompilationTarget webAssembly32
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_webAssembly64 [
	^ SLVMLLVMCompilationTarget webAssembly64
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_x86 [
	^ SLVMLLVMCompilationTarget x86
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_x86_64 [
	^ SLVMLLVMCompilationTarget x86_64
]

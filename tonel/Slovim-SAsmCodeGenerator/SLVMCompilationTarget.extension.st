Extension { #name : #SLVMCompilationTarget }

{ #category : #'*Slovim-SAsmCodeGenerator' }
SLVMCompilationTarget class >> x86 [
	^ SLVMSAsmCompilationTarget x86
]

{ #category : #'*Slovim-SAsmCodeGenerator' }
SLVMCompilationTarget class >> x86_64 [
	^ SLVMSAsmCompilationTarget x86_64
]

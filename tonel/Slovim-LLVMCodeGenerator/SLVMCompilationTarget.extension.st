Extension { #name : #SLVMCompilationTarget }

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_arm [
	^ SLVMLLVMCompilationTarget arm
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_arm64 [
	^ SLVMLLVMCompilationTarget arm64
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_armv5 [
	^ SLVMLLVMCompilationTarget armv5
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_armv6 [
	^ SLVMLLVMCompilationTarget armv6
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_armv6k [
	^ SLVMLLVMCompilationTarget armv6k
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_armv6m [
	^ SLVMLLVMCompilationTarget armv6m
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_armv7 [
	^ SLVMLLVMCompilationTarget armv7
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_armv7a [
	^ SLVMLLVMCompilationTarget armv7a
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_armv7m [
	^ SLVMLLVMCompilationTarget armv7m
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
SLVMCompilationTarget class >> llvm_mipsel [
	^ SLVMLLVMCompilationTarget mipsel
]

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

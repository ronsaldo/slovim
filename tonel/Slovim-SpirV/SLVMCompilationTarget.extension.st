Extension { #name : #SLVMCompilationTarget }

{ #category : #'*Slovim-SpirV' }
SLVMCompilationTarget >> isSpirV [
	^ false
]

{ #category : #'*Slovim-SpirV' }
SLVMCompilationTarget class >> spirv_logical32 [
	^ SLVMSpirV32CompilationTarget new logicalAddressMode: true
]

{ #category : #'*Slovim-SpirV' }
SLVMCompilationTarget class >> spirv_logical64 [
	^ SLVMSpirV64CompilationTarget new logicalAddressMode: true
]

{ #category : #'*Slovim-SpirV' }
SLVMCompilationTarget class >> spirv_physical32 [
	^ SLVMSpirV32CompilationTarget new logicalAddressMode: false
]

{ #category : #'*Slovim-SpirV' }
SLVMCompilationTarget class >> spirv_physical64 [
	^ SLVMSpirV64CompilationTarget new logicalAddressMode: false
]

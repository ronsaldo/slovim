Extension { #name : #WBTPlatform }

{ #category : #'*Slovim-LLVMCodeGenerator' }
WBTPlatform >> createSLVMCompilationTarget [
	^ (SLVMCompilationTarget perform: self slvmTargetName)
		operatingSystemName: name;
		canonicalOperatingSystemName: canonicalName;
		systemVendor: self systemVendor;
		abiName: self abiName;
		cpu: cpu;
		fpu: fpu;
		floatAbiName: floatAbiName;
		floatingPointModel: floatingPointModel;
		isEmbeddedPAL: isEmbeddedPAL;
		yourself
]

{ #category : #'*Slovim-LLVMCodeGenerator' }
WBTPlatform >> slvmTargetName [
	^ ('llvm_' , architecture fullCanonicalName) asSymbol
]

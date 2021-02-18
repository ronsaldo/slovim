Class {
	#name : #LLVMCConstants,
	#superclass : #SharedPool,
	#classVars : [
		'LLVMAMDGPUCSCallConv',
		'LLVMAMDGPUESCallConv',
		'LLVMAMDGPUGSCallConv',
		'LLVMAMDGPUHSCallConv',
		'LLVMAMDGPUKERNELCallConv',
		'LLVMAMDGPULSCallConv',
		'LLVMAMDGPUPSCallConv',
		'LLVMAMDGPUVSCallConv',
		'LLVMARMAAPCSCallConv',
		'LLVMARMAAPCSVFPCallConv',
		'LLVMARMAPCSCallConv',
		'LLVMAShr',
		'LLVMAVRBUILTINCallConv',
		'LLVMAVRINTRCallConv',
		'LLVMAVRSIGNALCallConv',
		'LLVMAdd',
		'LLVMAddrSpaceCast',
		'LLVMAlloca',
		'LLVMAnd',
		'LLVMAnyRegCallConv',
		'LLVMAppendingLinkage',
		'LLVMArgumentValueKind',
		'LLVMArrayTypeKind',
		'LLVMAtomicCmpXchg',
		'LLVMAtomicOrderingAcquire',
		'LLVMAtomicOrderingAcquireRelease',
		'LLVMAtomicOrderingMonotonic',
		'LLVMAtomicOrderingNotAtomic',
		'LLVMAtomicOrderingRelease',
		'LLVMAtomicOrderingSequentiallyConsistent',
		'LLVMAtomicOrderingUnordered',
		'LLVMAtomicRMW',
		'LLVMAtomicRMWBinOpAdd',
		'LLVMAtomicRMWBinOpAnd',
		'LLVMAtomicRMWBinOpFAdd',
		'LLVMAtomicRMWBinOpFSub',
		'LLVMAtomicRMWBinOpMax',
		'LLVMAtomicRMWBinOpMin',
		'LLVMAtomicRMWBinOpNand',
		'LLVMAtomicRMWBinOpOr',
		'LLVMAtomicRMWBinOpSub',
		'LLVMAtomicRMWBinOpUMax',
		'LLVMAtomicRMWBinOpUMin',
		'LLVMAtomicRMWBinOpXchg',
		'LLVMAtomicRMWBinOpXor',
		'LLVMAvailableExternallyLinkage',
		'LLVMBasicBlockValueKind',
		'LLVMBitCast',
		'LLVMBlockAddressValueKind',
		'LLVMBr',
		'LLVMCCallConv',
		'LLVMCXXFASTTLSCallConv',
		'LLVMCall',
		'LLVMCallBr',
		'LLVMCatchPad',
		'LLVMCatchRet',
		'LLVMCatchSwitch',
		'LLVMCleanupPad',
		'LLVMCleanupRet',
		'LLVMColdCallConv',
		'LLVMCommonLinkage',
		'LLVMConstantAggregateZeroValueKind',
		'LLVMConstantArrayValueKind',
		'LLVMConstantDataArrayValueKind',
		'LLVMConstantDataVectorValueKind',
		'LLVMConstantExprValueKind',
		'LLVMConstantFPValueKind',
		'LLVMConstantIntValueKind',
		'LLVMConstantPointerNullValueKind',
		'LLVMConstantStructValueKind',
		'LLVMConstantTokenNoneValueKind',
		'LLVMConstantVectorValueKind',
		'LLVMDLLExportLinkage',
		'LLVMDLLExportStorageClass',
		'LLVMDLLImportLinkage',
		'LLVMDLLImportStorageClass',
		'LLVMDSError',
		'LLVMDSNote',
		'LLVMDSRemark',
		'LLVMDSWarning',
		'LLVMDefaultStorageClass',
		'LLVMDefaultVisibility',
		'LLVMDoubleTypeKind',
		'LLVMExternalLinkage',
		'LLVMExternalWeakLinkage',
		'LLVMExtractElement',
		'LLVMExtractValue',
		'LLVMFAdd',
		'LLVMFCmp',
		'LLVMFDiv',
		'LLVMFMul',
		'LLVMFNeg',
		'LLVMFP128TypeKind',
		'LLVMFPExt',
		'LLVMFPToSI',
		'LLVMFPToUI',
		'LLVMFPTrunc',
		'LLVMFRem',
		'LLVMFSub',
		'LLVMFastCallConv',
		'LLVMFence',
		'LLVMFloatTypeKind',
		'LLVMFreeze',
		'LLVMFunctionTypeKind',
		'LLVMFunctionValueKind',
		'LLVMGHCCallConv',
		'LLVMGeneralDynamicTLSModel',
		'LLVMGetElementPtr',
		'LLVMGhostLinkage',
		'LLVMGlobalAliasValueKind',
		'LLVMGlobalIFuncValueKind',
		'LLVMGlobalUnnamedAddr',
		'LLVMGlobalVariableValueKind',
		'LLVMHHVMCCallConv',
		'LLVMHHVMCallConv',
		'LLVMHalfTypeKind',
		'LLVMHiPECallConv',
		'LLVMHiddenVisibility',
		'LLVMICmp',
		'LLVMIndirectBr',
		'LLVMInitialExecTLSModel',
		'LLVMInlineAsmDialectATT',
		'LLVMInlineAsmDialectIntel',
		'LLVMInlineAsmValueKind',
		'LLVMInsertElement',
		'LLVMInsertValue',
		'LLVMInstructionValueKind',
		'LLVMIntEQ',
		'LLVMIntNE',
		'LLVMIntSGE',
		'LLVMIntSGT',
		'LLVMIntSLE',
		'LLVMIntSLT',
		'LLVMIntToPtr',
		'LLVMIntUGE',
		'LLVMIntUGT',
		'LLVMIntULE',
		'LLVMIntULT',
		'LLVMIntegerTypeKind',
		'LLVMIntelOCLBICallConv',
		'LLVMInternalLinkage',
		'LLVMInvoke',
		'LLVMLShr',
		'LLVMLabelTypeKind',
		'LLVMLandingPad',
		'LLVMLandingPadCatch',
		'LLVMLandingPadFilter',
		'LLVMLinkOnceAnyLinkage',
		'LLVMLinkOnceODRAutoHideLinkage',
		'LLVMLinkOnceODRLinkage',
		'LLVMLinkerPrivateLinkage',
		'LLVMLinkerPrivateWeakLinkage',
		'LLVMLoad',
		'LLVMLocalDynamicTLSModel',
		'LLVMLocalExecTLSModel',
		'LLVMLocalUnnamedAddr',
		'LLVMMSP430BUILTINCallConv',
		'LLVMMSP430INTRCallConv',
		'LLVMMemoryDefValueKind',
		'LLVMMemoryPhiValueKind',
		'LLVMMemoryUseValueKind',
		'LLVMMetadataAsValueValueKind',
		'LLVMMetadataTypeKind',
		'LLVMModuleFlagBehaviorAppend',
		'LLVMModuleFlagBehaviorAppendUnique',
		'LLVMModuleFlagBehaviorError',
		'LLVMModuleFlagBehaviorOverride',
		'LLVMModuleFlagBehaviorRequire',
		'LLVMModuleFlagBehaviorWarning',
		'LLVMMul',
		'LLVMNoUnnamedAddr',
		'LLVMNotThreadLocal',
		'LLVMOr',
		'LLVMPHI',
		'LLVMPPC_FP128TypeKind',
		'LLVMPTXDeviceCallConv',
		'LLVMPTXKernelCallConv',
		'LLVMPointerTypeKind',
		'LLVMPreserveAllCallConv',
		'LLVMPreserveMostCallConv',
		'LLVMPrivateLinkage',
		'LLVMProtectedVisibility',
		'LLVMPtrToInt',
		'LLVMRealOEQ',
		'LLVMRealOGE',
		'LLVMRealOGT',
		'LLVMRealOLE',
		'LLVMRealOLT',
		'LLVMRealONE',
		'LLVMRealORD',
		'LLVMRealPredicateFalse',
		'LLVMRealPredicateTrue',
		'LLVMRealUEQ',
		'LLVMRealUGE',
		'LLVMRealUGT',
		'LLVMRealULE',
		'LLVMRealULT',
		'LLVMRealUNE',
		'LLVMRealUNO',
		'LLVMResume',
		'LLVMRet',
		'LLVMSDiv',
		'LLVMSExt',
		'LLVMSIToFP',
		'LLVMSPIRFUNCCallConv',
		'LLVMSPIRKERNELCallConv',
		'LLVMSRem',
		'LLVMSelect',
		'LLVMShl',
		'LLVMShuffleVector',
		'LLVMStore',
		'LLVMStructTypeKind',
		'LLVMSub',
		'LLVMSwiftCallConv',
		'LLVMSwitch',
		'LLVMTokenTypeKind',
		'LLVMTrunc',
		'LLVMUDiv',
		'LLVMUIToFP',
		'LLVMURem',
		'LLVMUndefValueValueKind',
		'LLVMUnreachable',
		'LLVMUserOp1',
		'LLVMUserOp2',
		'LLVMVAArg',
		'LLVMVectorTypeKind',
		'LLVMVoidTypeKind',
		'LLVMWeakAnyLinkage',
		'LLVMWeakODRLinkage',
		'LLVMWebKitJSCallConv',
		'LLVMWin64CallConv',
		'LLVMX8664SysVCallConv',
		'LLVMX86FastcallCallConv',
		'LLVMX86INTRCallConv',
		'LLVMX86RegCallCallConv',
		'LLVMX86StdcallCallConv',
		'LLVMX86ThisCallCallConv',
		'LLVMX86VectorCallCallConv',
		'LLVMX86_FP80TypeKind',
		'LLVMX86_MMXTypeKind',
		'LLVMXor',
		'LLVMZExt'
	],
	#category : #'LLVM-IR-API'
}

{ #category : #'class initialization' }
LLVMCConstants class >> initialize [
	self
		initializeOpcodes;
		initializeTypeKind;
		initializeLinkage;
		initializeVisibility;	
		initializeUnnamedAddr;
		initializeDLLStorageClass;
		initializeCallConv;
		initializeValueKind;
		initializeIntPredicate;
		initializeRealPredicate;
		initializeLandingPadClauseTy;
		initializeThreadLocalModel;
		initializeAtomicOrdering;
		initializeAtomicaRMWBinOp;
		initializeDiagnosticSeverity;
		initializeInlineAsmDialect;
		initializeModuleFlagBehavior
]

{ #category : #initialization }
LLVMCConstants class >> initializeAtomicOrdering [
  LLVMAtomicOrderingNotAtomic := 0.
  LLVMAtomicOrderingUnordered := 1.
  LLVMAtomicOrderingMonotonic := 2.
  LLVMAtomicOrderingAcquire := 4.
  LLVMAtomicOrderingRelease := 5.
  LLVMAtomicOrderingAcquireRelease := 6.
  LLVMAtomicOrderingSequentiallyConsistent := 7.
]

{ #category : #initialization }
LLVMCConstants class >> initializeAtomicaRMWBinOp [
    LLVMAtomicRMWBinOpXchg := 0.
    LLVMAtomicRMWBinOpAdd := 1.
    LLVMAtomicRMWBinOpSub := 2.
    LLVMAtomicRMWBinOpAnd := 3.
    LLVMAtomicRMWBinOpNand := 4.
    LLVMAtomicRMWBinOpOr := 5.
    LLVMAtomicRMWBinOpXor := 6.
    LLVMAtomicRMWBinOpMax := 7.
    LLVMAtomicRMWBinOpMin := 8.
    LLVMAtomicRMWBinOpUMax := 9.
    LLVMAtomicRMWBinOpUMin := 10.
    LLVMAtomicRMWBinOpFAdd := 11.
    LLVMAtomicRMWBinOpFSub := 12.
]

{ #category : #initialization }
LLVMCConstants class >> initializeCallConv [
  LLVMCCallConv             := 0.
  LLVMFastCallConv          := 8.
  LLVMColdCallConv          := 9.
  LLVMGHCCallConv           := 10.
  LLVMHiPECallConv          := 11.
  LLVMWebKitJSCallConv      := 12.
  LLVMAnyRegCallConv        := 13.
  LLVMPreserveMostCallConv  := 14.
  LLVMPreserveAllCallConv   := 15.
  LLVMSwiftCallConv         := 16.
  LLVMCXXFASTTLSCallConv    := 17.
  LLVMX86StdcallCallConv    := 64.
  LLVMX86FastcallCallConv   := 65.
  LLVMARMAPCSCallConv       := 66.
  LLVMARMAAPCSCallConv      := 67.
  LLVMARMAAPCSVFPCallConv   := 68.
  LLVMMSP430INTRCallConv    := 69.
  LLVMX86ThisCallCallConv   := 70.
  LLVMPTXKernelCallConv     := 71.
  LLVMPTXDeviceCallConv     := 72.
  LLVMSPIRFUNCCallConv      := 75.
  LLVMSPIRKERNELCallConv    := 76.
  LLVMIntelOCLBICallConv    := 77.
  LLVMX8664SysVCallConv     := 78.
  LLVMWin64CallConv         := 79.
  LLVMX86VectorCallCallConv := 80.
  LLVMHHVMCallConv          := 81.
  LLVMHHVMCCallConv         := 82.
  LLVMX86INTRCallConv       := 83.
  LLVMAVRINTRCallConv       := 84.
  LLVMAVRSIGNALCallConv     := 85.
  LLVMAVRBUILTINCallConv    := 86.
  LLVMAMDGPUVSCallConv      := 87.
  LLVMAMDGPUGSCallConv      := 88.
  LLVMAMDGPUPSCallConv      := 89.
  LLVMAMDGPUCSCallConv      := 90.
  LLVMAMDGPUKERNELCallConv  := 91.
  LLVMX86RegCallCallConv    := 92.
  LLVMAMDGPUHSCallConv      := 93.
  LLVMMSP430BUILTINCallConv := 94.
  LLVMAMDGPULSCallConv      := 95.
  LLVMAMDGPUESCallConv      := 96
]

{ #category : #initialization }
LLVMCConstants class >> initializeDLLStorageClass [
	LLVMDefaultStorageClass := 0.
	LLVMDLLImportStorageClass := 1.
	LLVMDLLExportStorageClass := 2.
]

{ #category : #initialization }
LLVMCConstants class >> initializeDiagnosticSeverity [
    LLVMDSError := 0.
    LLVMDSWarning := 1.
    LLVMDSRemark := 2.
    LLVMDSNote := 3.
]

{ #category : #initialization }
LLVMCConstants class >> initializeInlineAsmDialect [
  LLVMInlineAsmDialectATT := 0.
  LLVMInlineAsmDialectIntel := 1.
]

{ #category : #initialization }
LLVMCConstants class >> initializeIntPredicate [
	LLVMIntEQ := 32.
	LLVMIntNE := 33.
	LLVMIntUGT := 34.
	LLVMIntUGE := 35.
	LLVMIntULT := 36.
	LLVMIntULE := 37.
	LLVMIntSGT := 38.
	LLVMIntSGE := 39.
	LLVMIntSLT := 40.
	LLVMIntSLE := 41.
]

{ #category : #initialization }
LLVMCConstants class >> initializeLandingPadClauseTy [
	LLVMLandingPadCatch := 0.
	LLVMLandingPadFilter := 1.

]

{ #category : #initialization }
LLVMCConstants class >> initializeLinkage [
  LLVMExternalLinkage := 0.
  LLVMAvailableExternallyLinkage := 1.
  LLVMLinkOnceAnyLinkage := 2.
  LLVMLinkOnceODRLinkage := 3.
  LLVMLinkOnceODRAutoHideLinkage := 4.
  LLVMWeakAnyLinkage := 5.
  LLVMWeakODRLinkage := 6.
  LLVMAppendingLinkage := 7.
  LLVMInternalLinkage := 8.
  LLVMPrivateLinkage := 9.
  LLVMDLLImportLinkage := 10.
  LLVMDLLExportLinkage := 11.
  LLVMExternalWeakLinkage := 12.
  LLVMGhostLinkage := 13.
  LLVMCommonLinkage := 14.
  LLVMLinkerPrivateLinkage := 15.
  LLVMLinkerPrivateWeakLinkage := 16.
]

{ #category : #initialization }
LLVMCConstants class >> initializeModuleFlagBehavior [
  LLVMModuleFlagBehaviorError := 0.
  LLVMModuleFlagBehaviorWarning := 1.
  LLVMModuleFlagBehaviorRequire := 2.
  LLVMModuleFlagBehaviorOverride := 3.
  LLVMModuleFlagBehaviorAppend := 4.
  LLVMModuleFlagBehaviorAppendUnique := 5.
]

{ #category : #'class initialization' }
LLVMCConstants class >> initializeOpcodes [
  LLVMRet            := 1.
  LLVMBr             := 2.
  LLVMSwitch         := 3.
  LLVMIndirectBr     := 4.
  LLVMInvoke         := 5.
  LLVMUnreachable    := 7.
  LLVMCallBr         := 67.

  LLVMFNeg           := 66.

  LLVMAdd            := 8.
  LLVMFAdd           := 9.
  LLVMSub            := 10.
  LLVMFSub           := 11.
  LLVMMul            := 12.
  LLVMFMul           := 13.
  LLVMUDiv           := 14.
  LLVMSDiv           := 15.
  LLVMFDiv           := 16.
  LLVMURem           := 17.
  LLVMSRem           := 18.
  LLVMFRem           := 19.

  LLVMShl            := 20.
  LLVMLShr           := 21.
  LLVMAShr           := 22.
  LLVMAnd            := 23.
  LLVMOr             := 24.
  LLVMXor            := 25.

  LLVMAlloca         := 26.
  LLVMLoad           := 27.
  LLVMStore          := 28.
  LLVMGetElementPtr  := 29.

  LLVMTrunc          := 30.
  LLVMZExt           := 31.
  LLVMSExt           := 32.
  LLVMFPToUI         := 33.
  LLVMFPToSI         := 34.
  LLVMUIToFP         := 35.
  LLVMSIToFP         := 36.
  LLVMFPTrunc        := 37.
  LLVMFPExt          := 38.
  LLVMPtrToInt       := 39.
  LLVMIntToPtr       := 40.
  LLVMBitCast        := 41.
  LLVMAddrSpaceCast  := 60.

  LLVMICmp           := 42.
  LLVMFCmp           := 43.
  LLVMPHI            := 44.
  LLVMCall           := 45.
  LLVMSelect         := 46.
  LLVMUserOp1        := 47.
  LLVMUserOp2        := 48.
  LLVMVAArg          := 49.
  LLVMExtractElement := 50.
  LLVMInsertElement  := 51.
  LLVMShuffleVector  := 52.
  LLVMExtractValue   := 53.
  LLVMInsertValue    := 54.
  LLVMFreeze         := 68.

  LLVMFence          := 55.
  LLVMAtomicCmpXchg  := 56.
  LLVMAtomicRMW      := 57.

  LLVMResume         := 58.
  LLVMLandingPad     := 59.
  LLVMCleanupRet     := 61.
  LLVMCatchRet       := 62.
  LLVMCatchPad       := 63.
  LLVMCleanupPad     := 64.
  LLVMCatchSwitch    := 65.
]

{ #category : #initialization }
LLVMCConstants class >> initializeRealPredicate [
  LLVMRealPredicateFalse := 0.

  LLVMRealOEQ := 1.
  LLVMRealOGT := 2.
  LLVMRealOGE := 3.
  LLVMRealOLT := 4.
  LLVMRealOLE := 5.
  LLVMRealONE := 6.
  LLVMRealORD := 7.
  LLVMRealUNO := 8.
  LLVMRealUEQ := 9.
  LLVMRealUGT := 10.
  LLVMRealUGE := 11.
  LLVMRealULT := 12.
  LLVMRealULE := 13.
  LLVMRealUNE := 14.
  LLVMRealPredicateTrue := 15.
]

{ #category : #initialization }
LLVMCConstants class >> initializeThreadLocalModel [
  LLVMNotThreadLocal := 0.
  LLVMGeneralDynamicTLSModel := 1.
  LLVMLocalDynamicTLSModel := 2.
  LLVMInitialExecTLSModel := 3.
  LLVMLocalExecTLSModel := 4.
]

{ #category : #initialization }
LLVMCConstants class >> initializeTypeKind [
  LLVMVoidTypeKind := 0.
  LLVMHalfTypeKind := 1.
  LLVMFloatTypeKind := 2.
  LLVMDoubleTypeKind := 3.
  LLVMX86_FP80TypeKind := 4.
  LLVMFP128TypeKind := 5.
  LLVMPPC_FP128TypeKind := 6.
  LLVMLabelTypeKind := 7.
  LLVMIntegerTypeKind := 8.
  LLVMFunctionTypeKind := 9.
  LLVMStructTypeKind := 10.
  LLVMArrayTypeKind := 11.
  LLVMPointerTypeKind := 12.
  LLVMVectorTypeKind := 13.
  LLVMMetadataTypeKind := 14.
  LLVMX86_MMXTypeKind := 15.
  LLVMTokenTypeKind := 16.

]

{ #category : #initialization }
LLVMCConstants class >> initializeUnnamedAddr [
	LLVMNoUnnamedAddr := 0.
	LLVMLocalUnnamedAddr := 1.
	LLVMGlobalUnnamedAddr := 2.
]

{ #category : #initialization }
LLVMCConstants class >> initializeValueKind [
	LLVMArgumentValueKind := 0.
	LLVMBasicBlockValueKind := 1.
	LLVMMemoryUseValueKind := 2.
	LLVMMemoryDefValueKind := 3.
	LLVMMemoryPhiValueKind := 4.

	LLVMFunctionValueKind := 5.
	LLVMGlobalAliasValueKind := 6.
	LLVMGlobalIFuncValueKind := 7.
	LLVMGlobalVariableValueKind := 8.
	LLVMBlockAddressValueKind := 9.
	LLVMConstantExprValueKind := 10.
	LLVMConstantArrayValueKind := 11.
	LLVMConstantStructValueKind := 12.
	LLVMConstantVectorValueKind := 13.

	LLVMUndefValueValueKind := 14.
	LLVMConstantAggregateZeroValueKind := 15.
	LLVMConstantDataArrayValueKind := 16.
	LLVMConstantDataVectorValueKind := 17.
	LLVMConstantIntValueKind := 18.
	LLVMConstantFPValueKind := 19.
	LLVMConstantPointerNullValueKind := 20.
	LLVMConstantTokenNoneValueKind := 21.

	LLVMMetadataAsValueValueKind := 22.
	LLVMInlineAsmValueKind := 23.

	LLVMInstructionValueKind := 24.
]

{ #category : #initialization }
LLVMCConstants class >> initializeVisibility [
	LLVMDefaultVisibility := 0.
	LLVMHiddenVisibility := 1.
	LLVMProtectedVisibility := 2.
]

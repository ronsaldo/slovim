Class {
	#name : #LLVMGlobalValue,
	#superclass : #LLVMConstant,
	#instVars : [
		'linkage',
		'visibility',
		'dllStorageClass',
		'threadLocalMode',
		'metadata',
		'comdat',
		'ownerModule'
	],
	#classVars : [
		'AppendingLinkage',
		'AvailableExternallyLinkage',
		'CommonLinkage',
		'DLLExportStorageClass',
		'DLLImportStorageClass',
		'DLLStorageMap',
		'DefaultStorageClass',
		'DefaultVisibility',
		'ExternalLinkage',
		'ExternalWeakLinkage',
		'GeneralDynamicTLSModel',
		'HiddenVisibility',
		'InitialExecTLSModel',
		'InternalLinkage',
		'LinkOnceAnyLinkage',
		'LinkOnceODRLinkage',
		'LinkageMap',
		'LocalDynamicTLSModel',
		'LocalExecTLSModel',
		'NotThreadLocal',
		'PrivateLinkage',
		'ProtectedVisibility',
		'ThreadLocalModeMap',
		'VisibilityMap',
		'WeakAnyLinkage',
		'WeakODRLinkage'
	],
	#category : #'LLVM-IR-GlobalValues'
}

{ #category : #linkage }
LLVMGlobalValue class >> appendingLinkage [
	^ AppendingLinkage
]

{ #category : #linkage }
LLVMGlobalValue class >> availableExternallyLinkage [
	^ AvailableExternallyLinkage
]

{ #category : #linkage }
LLVMGlobalValue class >> commonLinkage [
	^ CommonLinkage
]

{ #category : #linkage }
LLVMGlobalValue class >> externalLinkage [
	^ ExternalLinkage
]

{ #category : #linkage }
LLVMGlobalValue class >> externalWeakLinkage [
	^ ExternalWeakLinkage
]

{ #category : #'thread local model' }
LLVMGlobalValue class >> generalDynamicTLSModel [
	^ GeneralDynamicTLSModel
]

{ #category : #initialization }
LLVMGlobalValue class >> initialize [

	self enumDefine: #(
		(ExternalLinkage external)
		(AvailableExternallyLinkage available_externally)
		(LinkOnceAnyLinkage linkonce)
		(LinkOnceODRLinkage linkonce_odr)
		(WeakAnyLinkage weak)
		(WeakODRLinkage weak_odr)
		(AppendingLinkage appending)
		(InternalLinkage internal)
		(PrivateLinkage private)
		(ExternalWeakLinkage extern_weak)
		(CommonLinkage common)
	).
	
	LinkageMap := Dictionary newFromPairs: { 
		ExternalLinkage . LLVMExternalLinkage.
		AvailableExternallyLinkage . LLVMAvailableExternallyLinkage.
		LinkOnceAnyLinkage . LLVMLinkOnceAnyLinkage.
		LinkOnceODRLinkage . LLVMLinkOnceODRLinkage.
		WeakAnyLinkage . LLVMWeakAnyLinkage.
		WeakODRLinkage . LLVMWeakODRLinkage.
		AppendingLinkage . LLVMAppendingLinkage.
		InternalLinkage . LLVMInternalLinkage.
		PrivateLinkage . LLVMPrivateLinkage.
		ExternalWeakLinkage . LLVMExternalWeakLinkage.
		CommonLinkage . LLVMCommonLinkage.
	}.

	self enumDefine: #(
		(DefaultVisibility default)
		(HiddenVisibility hidden)
		(ProtectedVisibility protected)
	).	

	VisibilityMap := Dictionary newFromPairs: { 
		DefaultVisibility . LLVMDefaultVisibility.
		HiddenVisibility . LLVMHiddenVisibility.
		ProtectedVisibility . LLVMProtectedVisibility.
	}.

	self enumDefine: #(
		(DefaultStorageClass #'')
		(DLLImportStorageClass dllimport)
		(DLLExportStorageClass dllexport)
	).	

	DLLStorageMap := Dictionary newFromPairs: { 
		DefaultStorageClass . LLVMDefaultStorageClass.
		DLLImportStorageClass . LLVMDLLImportStorageClass.
		LLVMDLLExportStorageClass . DLLExportStorageClass.
	}.

	self enumDefine: #(
		(NotThreadLocal #'')
		(GeneralDynamicTLSModel thread_local)
		(LocalDynamicTLSModel #'thread_local(localdynamic)')
		(InitialExecTLSModel #'thread_local(initialexec)')
		(LocalExecTLSModel #'thread_local(localexec)')
	).
	
	ThreadLocalModeMap := Dictionary newFromPairs: { 
		NotThreadLocal . LLVMNotThreadLocal.
		GeneralDynamicTLSModel . LLVMGeneralDynamicTLSModel.
		LocalDynamicTLSModel . LLVMLocalDynamicTLSModel.
		InitialExecTLSModel . LLVMInitialExecTLSModel.
		LocalExecTLSModel . LLVMLocalExecTLSModel.
	}.
]

{ #category : #linkage }
LLVMGlobalValue class >> internalLinkage [
	^ InternalLinkage
]

{ #category : #linkage }
LLVMGlobalValue class >> linkOnceAnyLinkage [
	^ LinkOnceAnyLinkage
]

{ #category : #linkage }
LLVMGlobalValue class >> linkOnceODRLinkage [
	^ LinkOnceODRLinkage
]

{ #category : #'thread local model' }
LLVMGlobalValue class >> notThreadLocal [
	^ NotThreadLocal
]

{ #category : #linkage }
LLVMGlobalValue class >> privateLinkage [
	^ PrivateLinkage
]

{ #category : #linkage }
LLVMGlobalValue class >> weakAnyLinkage [
	^ WeakAnyLinkage
]

{ #category : #linkage }
LLVMGlobalValue class >> weakODRLinkage [
	^ WeakODRLinkage
]

{ #category : #adding }
LLVMGlobalValue >> addDebugMetadata: metadataValue [
	^ self addNamed: #dbg metadata: metadataValue
]

{ #category : #adding }
LLVMGlobalValue >> addNamed: metadataName metadata: metadataValue [
	metadata := metadata copyWith: { metadataName . metadataValue}.
	^ metadataValue
]

{ #category : #accessing }
LLVMGlobalValue >> comdat [
	^ comdat
]

{ #category : #accessing }
LLVMGlobalValue >> comdat: anObject [
	comdat := anObject
]

{ #category : #accessing }
LLVMGlobalValue >> dllStorageClass [
	^ dllStorageClass
]

{ #category : #accessing }
LLVMGlobalValue >> dllStorageClass: anObject [
	dllStorageClass := anObject
]

{ #category : #printing }
LLVMGlobalValue >> fullPrintOn: aStream [
	self subclassResponsibility
]

{ #category : #testing }
LLVMGlobalValue >> hasAppendingLinkage [
	^ dllStorageClass == AppendingLinkage
]

{ #category : #testing }
LLVMGlobalValue >> hasAvailableExternallyLinkage [
	^ dllStorageClass == AvailableExternallyLinkage
]

{ #category : #testing }
LLVMGlobalValue >> hasCommonLinkage [
	^ dllStorageClass == CommonLinkage
]

{ #category : #testing }
LLVMGlobalValue >> hasDLLExportStorageClass [
	^ dllStorageClass == DLLExportStorageClass
]

{ #category : #testing }
LLVMGlobalValue >> hasDLLImportStorageClass [
	^ dllStorageClass == DLLImportStorageClass
]

{ #category : #testing }
LLVMGlobalValue >> hasDefaultVisibility [
	^ visibility == DefaultVisibility
]

{ #category : #testing }
LLVMGlobalValue >> hasExternalLinkage [
	^ dllStorageClass == ExternalLinkage
]

{ #category : #testing }
LLVMGlobalValue >> hasExternalWeakLinkage [
	^ dllStorageClass == ExternalWeakLinkage 
]

{ #category : #testing }
LLVMGlobalValue >> hasHiddenVisibility [
	^ visibility == HiddenVisibility
]

{ #category : #testing }
LLVMGlobalValue >> hasInternalLinkage [
	^ dllStorageClass == InternalLinkage
]

{ #category : #testing }
LLVMGlobalValue >> hasLinkOnceLinkage [
	^ dllStorageClass == LinkOnceAnyLinkage
]

{ #category : #testing }
LLVMGlobalValue >> hasLinkOnceODRLinkage [
	^ dllStorageClass == LinkOnceODRLinkage
]

{ #category : #testing }
LLVMGlobalValue >> hasPrivateLinkage [
	^ dllStorageClass == PrivateLinkage
]

{ #category : #testing }
LLVMGlobalValue >> hasProtectedVisibility [
	^ visibility == ProtectedVisibility
]

{ #category : #testing }
LLVMGlobalValue >> hasWeakAnyLinkage [
	^ dllStorageClass == WeakAnyLinkage
]

{ #category : #testing }
LLVMGlobalValue >> hasWeakLinkage [
	^ self hasWeakAnyLinkage or: [ self hasWeakODRLinkage ]
]

{ #category : #testing }
LLVMGlobalValue >> hasWeakODRLinkage [
	^ dllStorageClass == WeakODRLinkage
]

{ #category : #initialization }
LLVMGlobalValue >> initialize [
	super initialize.
	linkage := ExternalLinkage.
	visibility := DefaultVisibility.
	dllStorageClass := DefaultStorageClass.
	threadLocalMode := NotThreadLocal.
	metadata := #().
	
]

{ #category : #testing }
LLVMGlobalValue >> isThreadLocal [
	^ threadLocalMode ~~ NotThreadLocal
]

{ #category : #accessing }
LLVMGlobalValue >> linkage [
	^ linkage
]

{ #category : #accessing }
LLVMGlobalValue >> linkage: anObject [
	linkage := anObject
]

{ #category : #visibility }
LLVMGlobalValue >> makePrivate [
	self linkage: PrivateLinkage
]

{ #category : #accessing }
LLVMGlobalValue >> ownerModule [
	^ ownerModule
]

{ #category : #accessing }
LLVMGlobalValue >> ownerModule: aModule [
	^ ownerModule := aModule
]

{ #category : #printing }
LLVMGlobalValue >> printComdatOn: aStream [.
	comdat ifNil: [ ^ self ].
	aStream nextPutAll: ' comdat'.
	comdat name = name ifFalse: [
		aStream nextPut: $(; print: comdat; nextPut: $)
	].

]

{ #category : #printing }
LLVMGlobalValue >> printMetadataOn: aStream [
	| metadataName metadataValue |
	metadata doWithIndex: [ :metadataNamePair :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		
		metadataName := metadataNamePair first.
		metadataValue := metadataNamePair second.
		aStream nextPut: $!; nextPutAll: metadataName; space; print: metadataValue
	]
]

{ #category : #printing }
LLVMGlobalValue >> printOn: aStream [
	aStream nextPut: $@.
	name llvmPrintNameOn: aStream.
]

{ #category : #initialization }
LLVMGlobalValue >> setHandleNamedMetadata [
	| context |
	context := type context.
	metadata do: [ :each |
		handle setGlobalMetadata: (context getMDKindFor: each first) value: each second
	]
]

{ #category : #accessing }
LLVMGlobalValue >> threadLocalMode [
	^ threadLocalMode
]

{ #category : #accessing }
LLVMGlobalValue >> threadLocalMode: anObject [
	threadLocalMode := anObject
]

{ #category : #accessing }
LLVMGlobalValue >> visibility [
	^ visibility
]

{ #category : #accessing }
LLVMGlobalValue >> visibility: anObject [
	visibility := anObject
]

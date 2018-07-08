Class {
	#name : #LLVMGlobalValue,
	#superclass : #LLVMConstant,
	#instVars : [
		'linkage',
		'visibility',
		'dllStorageClass',
		'threadLocalMode',
		'metadata'
	],
	#classVars : [
		'AppendingLinkage',
		'AvailableExternallyLinkage',
		'CommonLinkage',
		'DLLExportStorageClass',
		'DLLImportStorageClass',
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
		'LocalDynamicTLSModel',
		'LocalExecTLSModel',
		'NotThreadLocal',
		'PrivateLinkage',
		'ProtectedVisibility',
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

	self enumDefine: #(
		(DefaultVisibility default)
		(HiddenVisibility hidden)
		(ProtectedVisibility protected)
	).	

	self enumDefine: #(
		(DefaultStorageClass #'')
		(DLLImportStorageClass dllimport)
		(DLLExportStorageClass dllexport)
	).	

	self enumDefine: #(
		(NotThreadLocal #'')
		(GeneralDynamicTLSModel thread_local)
		(LocalDynamicTLSModel #'thread_local(localdynamic)')
		(InitialExecTLSModel #'thread_local(initialexec)')
		(LocalExecTLSModel #'thread_local(localexec)')
	).
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

{ #category : #'as yet unclassified' }
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
	^ aStream nextPut: $@; nextPutAll: name
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

Class {
	#name : #LLVMDICompileUnit,
	#superclass : #LLVMDIScope,
	#instVars : [
		'language',
		'producer',
		'isOptimized',
		'runtimeVersion',
		'emissionKind',
		'enums',
		'globals'
	],
	#classVars : [
		'DwarfLanguageMap'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #'class initialization' }
LLVMDICompileUnit class >> initialize [
	DwarfLanguageMap := Dictionary newFromPairs: {
		#DW_LANG_C . LLVMDWARFSourceLanguageC.
		#DW_LANG_C_plus_plus . LLVMDWARFSourceLanguageC_plus_plus.
	}
]

{ #category : #'as yet unclassified' }
LLVMDICompileUnit >> doConcretizeWithDIBuilder: builder [
	handle := builder createCompileUnitWithLang: (DwarfLanguageMap at: language name) fileRef: file validHandle
		producer: producer producerLen: producer size
		isOptimized: (isOptimized ifNil: [false])
		runtimeVer: (runtimeVersion ifNil: [ 0 ])
		kind: 	emissionKind mapToDwarfEmissionKind dwoId: 0 splitDebugInlining: false
		debugInfoForProfiling: false
		sysRoot: nil sysRootLen: 0
		sdk: nil sdkLen: 0
]

{ #category : #accessing }
LLVMDICompileUnit >> emissionKind [
	^ emissionKind
]

{ #category : #accessing }
LLVMDICompileUnit >> emissionKind: anObject [
	emissionKind := anObject
]

{ #category : #accessing }
LLVMDICompileUnit >> enums [
	^ enums
]

{ #category : #accessing }
LLVMDICompileUnit >> enums: anObject [
	enums := anObject
]

{ #category : #accessing }
LLVMDICompileUnit >> globals [
	^ globals
]

{ #category : #accessing }
LLVMDICompileUnit >> globals: anObject [
	globals := anObject
]

{ #category : #initialization }
LLVMDICompileUnit >> initialize [
	super initialize.
	emissionKind := LLVMMDEnumValue new value: #FullDebug
]

{ #category : #accessing }
LLVMDICompileUnit >> isOptimized [
	^ isOptimized
]

{ #category : #accessing }
LLVMDICompileUnit >> isOptimized: anObject [
	isOptimized := anObject
]

{ #category : #accessing }
LLVMDICompileUnit >> language [
	^ language
]

{ #category : #accessing }
LLVMDICompileUnit >> language: anObject [
	language := anObject
]

{ #category : #accessing }
LLVMDICompileUnit >> producer [
	^ producer
]

{ #category : #accessing }
LLVMDICompileUnit >> producer: anObject [
	producer := anObject
]

{ #category : #accessing }
LLVMDICompileUnit >> runtimeVersion [
	^ runtimeVersion
]

{ #category : #accessing }
LLVMDICompileUnit >> runtimeVersion: anObject [
	runtimeVersion := anObject
]

{ #category : #accessing }
LLVMDICompileUnit >> specializedName [
	^ #DICompileUnit
]

{ #category : #accessing }
LLVMDICompileUnit >> specializedProperties [
	^ super specializedProperties , #(
		language
		producer
		isOptimized
		runtimeVersion
		emissionKind
		enums
		globals
	)
]

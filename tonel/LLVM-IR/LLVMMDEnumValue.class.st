Class {
	#name : #LLVMMDEnumValue,
	#superclass : #LLVMMetadata,
	#instVars : [
		'value'
	],
	#classVars : [
		'DwarfEmissionKindMap'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #'class initialization' }
LLVMMDEnumValue class >> initialize [
	DwarfEmissionKindMap := Dictionary newFromPairs: { 
		#FullDebug . LLVMDWARFEmissionFull
	}
	
]

{ #category : #printing }
LLVMMDEnumValue >> llvmPrintSpecializedMetadataValueOn: aStream [
	aStream nextPutAll: value
]

{ #category : #'as yet unclassified' }
LLVMMDEnumValue >> mapToDwarfEmissionKind [
	^ DwarfEmissionKindMap at: value
]

{ #category : #accessing }
LLVMMDEnumValue >> value [
	^ value
]

{ #category : #accessing }
LLVMMDEnumValue >> value: anObject [
	value := anObject
]

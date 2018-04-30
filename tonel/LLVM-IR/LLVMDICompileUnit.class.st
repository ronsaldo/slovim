Class {
	#name : #LLVMDICompileUnit,
	#superclass : #LLVMDIScope,
	#instVars : [
		'language',
		'producer',
		'isOptimized',
		'runtimeVersion',
		'emissionKind',
		'enums'
	],
	#category : #'LLVM-IR-Metadata'
}

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
	)
]

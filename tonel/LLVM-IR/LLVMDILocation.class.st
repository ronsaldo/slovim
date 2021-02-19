Class {
	#name : #LLVMDILocation,
	#superclass : #LLVMMDNode,
	#instVars : [
		'line',
		'column',
		'scope'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDILocation >> column [
	^ column
]

{ #category : #accessing }
LLVMDILocation >> column: anObject [
	column := anObject
]

{ #category : #'as yet unclassified' }
LLVMDILocation >> doConcretizeWithDIBuilder: builder [
	handle := builder createLocationLine: line column: column scope: scope validHandle inlinedAt: LLVMMetadataRef null
]

{ #category : #accessing }
LLVMDILocation >> line [
	^ line
]

{ #category : #accessing }
LLVMDILocation >> line: anObject [
	line := anObject
]

{ #category : #accessing }
LLVMDILocation >> scope [
	^ scope
]

{ #category : #accessing }
LLVMDILocation >> scope: anObject [
	scope := anObject
]

{ #category : #accessing }
LLVMDILocation >> specializedName [
	^ #DILocation
]

{ #category : #accessing }
LLVMDILocation >> specializedProperties [
	^ #( line column scope )
]

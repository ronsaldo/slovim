Class {
	#name : #LLVMDISubroutineType,
	#superclass : #LLVMDIType,
	#instVars : [
		'types'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #'as yet unclassified' }
LLVMDISubroutineType >> doConcretizeWithDIBuilder: builder [
	handle := builder createSubroutineTypeInFile: (file ifNil: [ LLVMMetadataRef null ]ifNotNil: [file validHandle]) parameters: (LLVMMetadataRefArray withAll: types elements) getHandle count: types elements size flags: (flags ifNil: [ 0 ] ifNotNil: [ flags mapToDIFlags ])
]

{ #category : #accessing }
LLVMDISubroutineType >> specializedName [
	^ #DISubroutineType
]

{ #category : #accessing }
LLVMDISubroutineType >> specializedProperties [
	^ super specializedProperties , #( types )
]

{ #category : #accessing }
LLVMDISubroutineType >> types [
	^ types
]

{ #category : #accessing }
LLVMDISubroutineType >> types: anObject [
	types := anObject
]

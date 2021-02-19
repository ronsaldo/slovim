Class {
	#name : #LLVMDILocalVariable,
	#superclass : #LLVMDIVariable,
	#instVars : [
		'arg'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDILocalVariable >> arg [
	^ arg
]

{ #category : #accessing }
LLVMDILocalVariable >> arg: anObject [
	arg := anObject
]

{ #category : #'as yet unclassified' }
LLVMDILocalVariable >> doConcretizeWithDIBuilder: builder [
	arg ifNil: [ 
		handle := builder createAutoVariableIn: scope validHandle name: name len: name size file: file line: line type: type validHandle alwaysPreserve: false flags: (flags ifNil: [ 0 ] ifNotNil: [flags mapToDIFlags ]) align: 0
	] ifNotNil: [
		handle := builder createParameterVariableIn: scope validHandle name: name len: name size argNo: arg file: file validHandle line: line type: type validHandle alwaysPreserve: false flags: (flags ifNil: [ 0 ] ifNotNil: [flags mapToDIFlags ])
	]
]

{ #category : #accessing }
LLVMDILocalVariable >> specializedName [
	^ #DILocalVariable
]

{ #category : #accessing }
LLVMDILocalVariable >> specializedProperties [
	^ super specializedProperties , #( arg )
]

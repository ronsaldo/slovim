Class {
	#name : #LLVMDIBasicType,
	#superclass : #LLVMDIType,
	#instVars : [
		'encoding'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #'as yet unclassified' }
LLVMDIBasicType >> doConcretizeWithDIBuilder: builder [
	handle := builder createBasicTypeNamed: name len: name size sizeInBits: size encoding: encoding value flags: (flags ifNil: [ 0 ] ifNotNil: [ flags mapToDIFlags ])
]

{ #category : #accessing }
LLVMDIBasicType >> encoding [
	^ encoding
]

{ #category : #accessing }
LLVMDIBasicType >> encoding: anObject [
	encoding := anObject
]

{ #category : #accessing }
LLVMDIBasicType >> specializedName [
	^ #DIBasicType
]

{ #category : #accessing }
LLVMDIBasicType >> specializedProperties [
	^ (super specializedProperties copyWithout: #scope) ,  #(encoding)
]

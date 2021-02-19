Class {
	#name : #LLVMDIDerivedType,
	#superclass : #LLVMDIType,
	#instVars : [
		'tag',
		'baseType',
		'offset'
	],
	#classVars : [
		'DerivedConcretizeKindDispatchTable'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #'class initialization' }
LLVMDIDerivedType class >> initialize [
	DerivedConcretizeKindDispatchTable := Dictionary newFromPairs: #(
		DW_TAG_reference_type concretizeReferenceType:
		DW_TAG_rvalue_reference_type concretizeReferenceType:
		DW_TAG_pointer_type concretizePointerType:
		DW_TAG_member concretizeMemberType:
		DW_TAG_inheritance concretizeInheritanceType:
		DW_TAG_const_type concretizeQualifiedType:
	)
]

{ #category : #accessing }
LLVMDIDerivedType >> baseType [
	^ baseType
]

{ #category : #accessing }
LLVMDIDerivedType >> baseType: anObject [
	baseType := anObject
]

{ #category : #'as yet unclassified' }
LLVMDIDerivedType >> concretizeInheritanceType: builder [
	handle := builder createInheritanceIn: scope validHandle baseType: baseType baseOffset: offset vbptrOffset: 0 flags: (flags ifNil: [ 0 ] ifNotNil: [flags mapToDIFlags])
]

{ #category : #'as yet unclassified' }
LLVMDIDerivedType >> concretizeMemberType: builder [
	handle := builder createMemberIn: scope validHandle name: name len: name size
	file: (file ifNil: [ LLVMMetadataRef null ] ifNotNil: [file validHandle]) line: 0
	size: size alignInBits: (align ifNil: [0]) offsetInBits: offset
	flags: (flags ifNil: [0] ifNotNil: [flags mapToDIFlags])
	type: baseType validHandle
]

{ #category : #'as yet unclassified' }
LLVMDIDerivedType >> concretizePointerType: builder [
	handle := builder createPointerType: (baseType ifNil: [ LLVMMetadataRef null ] ifNotNil: [baseType validHandle]) size: size align: align addressSpace: 0 name: (name ifNil: [nil]) nameLen: (name ifNil: [ 0 ] ifNotNil: [name size])
]

{ #category : #'as yet unclassified' }
LLVMDIDerivedType >> concretizeQualifiedType: builder [
	handle := builder createQualifiedType: (baseType ifNil: [ LLVMMetadataRef null ] ifNotNil: [baseType validHandle]) tag: tag value
]

{ #category : #'as yet unclassified' }
LLVMDIDerivedType >> concretizeReferenceType: builder [
	handle := builder createReferenceType: baseType validHandle tag: tag value
]

{ #category : #'as yet unclassified' }
LLVMDIDerivedType >> doConcretizeWithDIBuilder: builder [
	self perform: (DerivedConcretizeKindDispatchTable at: tag name) with: builder
]

{ #category : #accessing }
LLVMDIDerivedType >> offset [
	^ offset
]

{ #category : #accessing }
LLVMDIDerivedType >> offset: anObject [
	offset := anObject
]

{ #category : #accessing }
LLVMDIDerivedType >> requiredProperties [
	^ #(baseType)
]

{ #category : #accessing }
LLVMDIDerivedType >> specializedName [
	^ #DIDerivedType
]

{ #category : #accessing }
LLVMDIDerivedType >> specializedProperties [
	^ super specializedProperties , #(tag baseType offset)
]

{ #category : #accessing }
LLVMDIDerivedType >> tag [
	^ tag
]

{ #category : #accessing }
LLVMDIDerivedType >> tag: anObject [
	tag := anObject
]

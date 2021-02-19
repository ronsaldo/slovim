Class {
	#name : #LLVMDICompositeType,
	#superclass : #LLVMDIType,
	#instVars : [
		'tag',
		'elements',
		'baseType',
		'identifier',
		'templateParams'
	],
	#classVars : [
		'CompositeConcretizeKindDispatchTable'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #'class initialization' }
LLVMDICompositeType class >> initialize [
	CompositeConcretizeKindDispatchTable := Dictionary newFromPairs: #(
		DW_TAG_structure_type concretizeStructureType:
		DW_TAG_class_type concretizeClassType:
		DW_TAG_enumeration_type concretizeEnumerationType:
		DW_TAG_union_type concretizeUnionType:
		DW_TAG_array_type concretizeArrayType:
	)
]

{ #category : #accessing }
LLVMDICompositeType >> baseType [
	^ baseType
]

{ #category : #accessing }
LLVMDICompositeType >> baseType: anObject [
	baseType := anObject
]

{ #category : #'as yet unclassified' }
LLVMDICompositeType >> concretizeArrayType: builder [
	handle := builder createArrayType: baseType validHandle size: size align: align subscripts: (LLVMMetadataRefArray withAll: elements elements) getHandle count: elements elements size
]

{ #category : #'as yet unclassified' }
LLVMDICompositeType >> concretizeClassType: builder [
	| validName |
	validName := name ifNil: [ '' ].
	handle := builder createClassTypeIn: scope validHandle
		name: validName len: validName size
		file: file validHandle line: 0
		size: (size ifNil: [0]) align: (align ifNil: [0])
		flags: (flags ifNil: [ 0 ] ifNotNil: [flags mapToDIFlags])
		derivedFrom: (baseType ifNil: [LLVMMetadataRef null] ifNotNil: [baseType validHandle])
		elements: (LLVMMetadataRefArray withAll: elements elements) getHandle count: elements elements size
		vtableHolder: LLVMMetadataRef null
		templateParams: templateParams
		uniqueId: identifier uniqueIdLen: identifier size
]

{ #category : #'as yet unclassified' }
LLVMDICompositeType >> concretizeEnumerationType: builder [
	handle := builder createEnumerationTypeIn: scope validHandle name: name len: name size
	file: file validHandle line: 0
	size: size align: align
	elements: (LLVMMetadataRefArray withAll: elements elements) getHandle count: elements elements size classType: baseType validHandle
]

{ #category : #'as yet unclassified' }
LLVMDICompositeType >> concretizeStructureType: builder [
	| validName |
	validName := name ifNil: [ '' ].
	handle := builder createStructTypeIn: scope validHandle
		name: validName len: validName size
		file: file validHandle line: 0
		size: (size ifNil: [0]) align: (align ifNil: [0])
		flags: (flags ifNil: [ 0 ] ifNotNil: [flags mapToDIFlags])
		derivedFrom: (baseType ifNil: [LLVMMetadataRef null] ifNotNil: [baseType validHandle])
		elements: (LLVMMetadataRefArray withAll: elements elements) getHandle count: elements elements size
		runtimeLang: 0 vtableHolder: LLVMMetadataRef null
		uniqueId: identifier uniqueIdLen: identifier size
]

{ #category : #'as yet unclassified' }
LLVMDICompositeType >> concretizeUnionType: builder [
	| validName |
	validName := name ifNil: [ '' ].
	handle := builder createUnionTypeIn: scope validHandle
		name: validName len: validName size
		file: file validHandle line: 0
		size: (size ifNil: [0]) align: (align ifNil: [0])
		flags: (flags ifNil: [ 0 ] ifNotNil: [flags mapToDIFlags])
		elements: (LLVMMetadataRefArray withAll: elements elements) getHandle count: elements elements size
		runtimeLang: 0
		uniqueId: identifier uniqueIdLen: identifier size
]

{ #category : #'as yet unclassified' }
LLVMDICompositeType >> doConcretizeWithDIBuilder: builder [
	self perform: (CompositeConcretizeKindDispatchTable at: tag name) with: builder
]

{ #category : #accessing }
LLVMDICompositeType >> elements [
	^ elements
]

{ #category : #accessing }
LLVMDICompositeType >> elements: anObject [
	elements := anObject
]

{ #category : #accessing }
LLVMDICompositeType >> identifier [
	^ identifier
]

{ #category : #accessing }
LLVMDICompositeType >> identifier: anObject [
	identifier := anObject
]

{ #category : #accessing }
LLVMDICompositeType >> specializedName [
	^ #DICompositeType
]

{ #category : #accessing }
LLVMDICompositeType >> specializedProperties [
	^ super specializedProperties , #(tag elements baseType identifier)
]

{ #category : #accessing }
LLVMDICompositeType >> tag [
	^ tag
]

{ #category : #accessing }
LLVMDICompositeType >> tag: anObject [
	tag := anObject
]

{ #category : #accessing }
LLVMDICompositeType >> templateParams [

	^ templateParams
]

{ #category : #accessing }
LLVMDICompositeType >> templateParams: anObject [

	templateParams := anObject
]

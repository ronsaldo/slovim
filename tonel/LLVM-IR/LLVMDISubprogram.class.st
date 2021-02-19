Class {
	#name : #LLVMDISubprogram,
	#superclass : #LLVMDILocalScope,
	#instVars : [
		'linkageName',
		'isLocal',
		'isDefinition',
		'line',
		'type',
		'scopeLine',
		'unit',
		'retainedNodes'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #'as yet unclassified' }
LLVMDISubprogram >> doConcretizeWithDIBuilder: builder [
	| validName validLinkageName |
	validName := name ifNil: [ '' ].
	validLinkageName := linkageName ifNil: [ '' ].

	handle := builder createFunctionInScope: scope validHandle
		name: validName nameLen: validName size
		linkageName: validLinkageName linkageNameLen: validLinkageName size
		file: file validHandle lineNo: line type: type
		isLocalToUnit: isLocal  isDefinition: isDefinition
		scopeLine: scopeLine flags: (flags ifNil: [ 0 ] ifNotNil: [ flags mapToDIFlags ]) optimized: false
]

{ #category : #accessing }
LLVMDISubprogram >> isDefinition [
	^ isDefinition
]

{ #category : #accessing }
LLVMDISubprogram >> isDefinition: anObject [
	isDefinition := anObject
]

{ #category : #accessing }
LLVMDISubprogram >> isLocal [
	^ isLocal
]

{ #category : #accessing }
LLVMDISubprogram >> isLocal: anObject [
	isLocal := anObject
]

{ #category : #accessing }
LLVMDISubprogram >> line [
	^ line
]

{ #category : #accessing }
LLVMDISubprogram >> line: anObject [
	line := anObject
]

{ #category : #accessing }
LLVMDISubprogram >> linkageName [
	^ linkageName
]

{ #category : #accessing }
LLVMDISubprogram >> linkageName: anObject [
	linkageName := anObject
]

{ #category : #accessing }
LLVMDISubprogram >> retainedNodes [
	^ retainedNodes
]

{ #category : #accessing }
LLVMDISubprogram >> retainedNodes: anObject [
	retainedNodes := anObject
]

{ #category : #accessing }
LLVMDISubprogram >> scopeLine [
	^ scopeLine
]

{ #category : #accessing }
LLVMDISubprogram >> scopeLine: anObject [
	scopeLine := anObject
]

{ #category : #accessing }
LLVMDISubprogram >> specializedName [
	^ #DISubprogram
]

{ #category : #accessing }
LLVMDISubprogram >> specializedProperties [
	^ super specializedProperties , #(linkageName isDefinition isLocal line scopeLine type unit retainedNodes)
]

{ #category : #accessing }
LLVMDISubprogram >> type [
	^ type
]

{ #category : #accessing }
LLVMDISubprogram >> type: anObject [
	type := anObject
]

{ #category : #accessing }
LLVMDISubprogram >> unit [
	^ unit
]

{ #category : #accessing }
LLVMDISubprogram >> unit: anObject [
	unit := anObject
]

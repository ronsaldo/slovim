Class {
	#name : #LLVMDISubprogram,
	#superclass : #LLVMDILocalScope,
	#instVars : [
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
	^ super specializedProperties , #(isDefinition isLocal line scopeLine type unit retainedNodes)
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

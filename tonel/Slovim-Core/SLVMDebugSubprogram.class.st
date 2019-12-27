Class {
	#name : #SLVMDebugSubprogram,
	#superclass : #SLVMDebugLocalScope,
	#instVars : [
		'isLocal',
		'isDefinition',
		'type'
	],
	#category : #'Slovim-Core-Debug'
}

{ #category : #visiting }
SLVMDebugSubprogram >> accept: visitor [
	^ visitor visitDebugSubprogram: self
]

{ #category : #accessing }
SLVMDebugSubprogram >> isDefinition [
	^ isDefinition
]

{ #category : #accessing }
SLVMDebugSubprogram >> isDefinition: anObject [
	isDefinition := anObject
]

{ #category : #accessing }
SLVMDebugSubprogram >> isLocal [
	^ isLocal
]

{ #category : #accessing }
SLVMDebugSubprogram >> isLocal: anObject [
	isLocal := anObject
]

{ #category : #accessing }
SLVMDebugSubprogram >> type [
	^ type
]

{ #category : #accessing }
SLVMDebugSubprogram >> type: anObject [
	type := anObject
]

Class {
	#name : #LLVMNamedFlags,
	#superclass : #LLVMMetadata,
	#instVars : [
		'flags'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #'instance creation' }
LLVMNamedFlags class >> with: flags [
	^ self new flags: flags
]

{ #category : #accessing }
LLVMNamedFlags >> flags [
	^ flags
]

{ #category : #accessing }
LLVMNamedFlags >> flags: anObject [
	flags := anObject
]

{ #category : #printing }
LLVMNamedFlags >> llvmPrintSpecializedMetadataValueOn: aStream [
	self printOn: aStream
	
]

{ #category : #printing }
LLVMNamedFlags >> printOn: aStream [
	flags doWithIndex: [ :flag :index |
		index > 1 ifTrue: [ aStream nextPutAll: ' | ' ].
		aStream nextPutAll: flag
	]
]

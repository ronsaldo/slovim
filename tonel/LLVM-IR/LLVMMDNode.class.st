Class {
	#name : #LLVMMDNode,
	#superclass : #LLVMMetadata,
	#instVars : [
		'context',
		'metadataName',
		'isDistinct',
		'forwarder'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #'instance creation' }
LLVMMDNode class >> for: aModule [
	^ aModule addMetadata: self new
]

{ #category : #'instance creation' }
LLVMMDNode class >> named: aName for: aModule [
	^ aModule addMetadata: (self new metadataName: aName; yourself)
]

{ #category : #'as yet unclassified' }
LLVMMDNode >> concretizeWithDIBuilder: aBuilder [
	forwarder ifNotNil: [ 
		self doConcretizeWithDIBuilder: aBuilder.
	
		forwarder replaceAllUsesWith: handle.
		forwarder := nil.
	]
]

{ #category : #accessing }
LLVMMDNode >> context [

	^ context
]

{ #category : #accessing }
LLVMMDNode >> context: anObject [

	context := anObject
]

{ #category : #'as yet unclassified' }
LLVMMDNode >> createForwarder [
	handle := forwarder := context validHandle temporaryMDNode: nil count: 0
]

{ #category : #'as yet unclassified' }
LLVMMDNode >> distinct [
	isDistinct := true
]

{ #category : #'as yet unclassified' }
LLVMMDNode >> doConcretizeWithDIBuilder: aBuilder [
	self subclassResponsibility
]

{ #category : #printing }
LLVMMDNode >> fullPrintOn: aStream [
	self printOn: aStream.
	aStream nextPutAll: ' = '.
	isDistinct ifTrue: [ aStream nextPutAll: 'distinct ' ].
	self specializedName ifNil: [ 
		aStream nextPutAll: '!{'.
		self printContentOn: aStream.
		aStream nextPut: $}.
	] ifNotNil: [ :specializedName |
		aStream nextPut: $!; nextPutAll: specializedName; nextPut: $(.
		self printSpecializedContentOn: aStream.
		aStream nextPut: $).
	].

]

{ #category : #initialization }
LLVMMDNode >> initialize [
	super initialize.
	isDistinct := false.
	
]

{ #category : #accessing }
LLVMMDNode >> isDistinct [
	^ isDistinct
]

{ #category : #'as yet unclassified' }
LLVMMDNode >> llvmPrintSpecializedMetadataValueOn: aStream [
	self printOn: aStream
]

{ #category : #accessing }
LLVMMDNode >> metadataName [
	^ metadataName
]

{ #category : #accessing }
LLVMMDNode >> metadataName: anObject [
	metadataName := anObject
]

{ #category : #printing }
LLVMMDNode >> printContentOn: aStream [
	self subclassResponsibility
]

{ #category : #printing }
LLVMMDNode >> printOn: aStream [
	aStream nextPut: $!; nextPutAll: metadataName
]

{ #category : #printing }
LLVMMDNode >> printSpecializedContentOn: aStream [
	| destIndex value propertyName propertySelector requiredProperties |
	destIndex := 0.
	requiredProperties := self requiredProperties.
	self specializedProperties do: [ :property |
		propertyName := property.
		propertySelector := property.
		property isArray ifTrue: [ 
			propertyName := property first.
			propertySelector := property second.
		].
	
		value := self perform: propertySelector.
		
		(value isNotNil or: [requiredProperties includes: propertyName]) ifTrue: [
			destIndex > 0 ifTrue: [
				aStream nextPutAll: ', '
			].
		
			aStream nextPutAll: propertyName; nextPutAll: ': '.
			value llvmPrintSpecializedMetadataValueOn: aStream.
			destIndex := destIndex + 1
		].
	]
]

{ #category : #'as yet unclassified' }
LLVMMDNode >> replaceHandleAllUsesWith: newHandle [
	handle replaceAllUsesWith: newHandle.
	handle := newHandle.
	forwarder := nil.
]

{ #category : #accessing }
LLVMMDNode >> requiredProperties [
	^ #()
]

{ #category : #accessing }
LLVMMDNode >> specializedName [
	^ nil
]

{ #category : #accessing }
LLVMMDNode >> specializedProperties [
	^ self subclassResponsibility
]

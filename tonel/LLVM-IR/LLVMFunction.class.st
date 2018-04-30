Class {
	#name : #LLVMFunction,
	#superclass : #LLVMGlobalObject,
	#instVars : [
		'functionType',
		'basicBlocks',
		'callingConvenction',
		'arguments',
		'symbolGenerationCount',
		'hasArgumentNames'
	],
	#category : #'LLVM-IR-GlobalValues'
}

{ #category : #'as yet unclassified' }
LLVMFunction class >> createWithType: functionType linkage: linkage [
	^ self createWithType: functionType linkage: linkage name: nil module: nil
]

{ #category : #'as yet unclassified' }
LLVMFunction class >> createWithType: functionType linkage: linkage name: aName [
	^ self createWithType: functionType linkage: linkage name: aName module: nil
]

{ #category : #'as yet unclassified' }
LLVMFunction class >> createWithType: functionType linkage: linkage name: aName module: module [
	^ self new initializeWithType: functionType linkage: linkage name: aName module: module
]

{ #category : #adding }
LLVMFunction >> addBasicBlock: basicBlock [
	^ self addBasicBlock: basicBlock before: nil
]

{ #category : #adding }
LLVMFunction >> addBasicBlock: basicBlock before: previousBasicBlock [
	basicBlock parent: self.
	basicBlocks add: basicBlock

]

{ #category : #accessing }
LLVMFunction >> arguments [
	^ arguments
]

{ #category : #accessing }
LLVMFunction >> basicBlocks [
	^ basicBlocks
]

{ #category : #printing }
LLVMFunction >> fullPrintOn: aStream [
	self sanitizeNames.
	basicBlocks ifEmpty: [
		aStream << 'declare ' << linkage second << ' ' << visibility second << ' ' << dllStorageClass  second << callingConvenction << ' ' <<
		functionType returnType name << ' @' << self name << ' ( '.
		
		arguments doWithIndex: [ :arg :index |
			index > 1 ifTrue: [ aStream << ', ' ].
			arg printOnDeclaration: aStream
		].
	
		functionType isVarArg ifTrue: [ 
			arguments ifNotEmpty: [ aStream nextPutAll: ', ' ].
			aStream nextPutAll: '...' .
		].
		
		aStream << ' )'.
		^ self
	].

	aStream << 'define ' << linkage second << ' ' << visibility second << ' ' << dllStorageClass  second << callingConvenction << ' ' <<
	functionType returnType name << ' @' << self name << ' ( '.
	
	arguments doWithIndex: [ :arg :index |
			index > 1 ifTrue: [ aStream << ', ' ].
			arg printOnDefinition: aStream
	].

	functionType isVarArg ifTrue: [ 
		arguments ifNotEmpty: [ aStream nextPutAll: ', ' ].
		aStream nextPutAll: '...' .
	].

	aStream << ' )'.
	self printMetadataOn: aStream.
	aStream nextPutAll: ' {'; lf.
	basicBlocks do: [ :bb | bb fullPrintOn: aStream ].
	aStream << '}'; lf.

	
]

{ #category : #initialization }
LLVMFunction >> generateSymbol [
	| result |
	result := symbolGenerationCount asString.
	symbolGenerationCount := symbolGenerationCount + 1.
	^ result
]

{ #category : #accessing }
LLVMFunction >> hasArgumentNames [
	^ hasArgumentNames
]

{ #category : #initialization }
LLVMFunction >> initialize [
	super initialize.
	basicBlocks := OrderedCollection new.
	callingConvenction := #ccc.
	symbolGenerationCount := 0.
	hasArgumentNames := false.
	
]

{ #category : #initialization }
LLVMFunction >> initializeWithType: theFunctionType linkage: theLinkage name: theName module: theModule [
	self assert: theFunctionType isFunctionTy.
	functionType := theFunctionType.
	self linkage: theLinkage.
	self name: theName.
	self type: (LLVMPointerType getUnqual: functionType).
	theModule ifNotNil: [
		theModule addGlobalValue: self
	].

	arguments := functionType params collectWithIndex: [ :param :index |
		LLVMArgument new
			parent: self;
			argNo: index - 1;
			type: param;
			yourself
	].

]

{ #category : #printing }
LLVMFunction >> printMetadataOn: aStream [
	| metadataName metadataValue |
	metadata doWithIndex: [ :metadataNamePair :index |
		metadataName := metadataNamePair first.
		metadataValue := metadataNamePair second.
		aStream space; nextPut: $!; nextPutAll: metadataName; space; print: metadataValue
	]
]

{ #category : #accessing }
LLVMFunction >> returnType [
	^ functionType returnType
]

{ #category : #printing }
LLVMFunction >> sanitizeNames [
	arguments do: [ :arg | arg name ifNil: [ arg name: self generateSymbol ] ].
	basicBlocks do: [ :bb |
		bb name ifNil: [ bb name: self generateSymbol ].
		bb instructionsDo: [ :instruction  |
			instruction name ifNil: [
				instruction type isVoidTy ifFalse: [ 
					instruction name: self generateSymbol
				]
			]
		]
	]
]

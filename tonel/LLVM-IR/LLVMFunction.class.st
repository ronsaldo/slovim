Class {
	#name : #LLVMFunction,
	#superclass : #LLVMGlobalObject,
	#instVars : [
		'functionType',
		'basicBlocks',
		'arguments',
		'symbolGenerationCount',
		'hasArgumentNames',
		'labelSymbolGenerationCount',
		'gcStrategy',
		'personalityFunction',
		'returnAttributes',
		'functionAttributes',
		'callingConvention'
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

{ #category : #initialization }
LLVMFunction >> addFunctionAttribute: anAttribute [
	functionAttributes := functionAttributes copyWith: anAttribute
]

{ #category : #initialization }
LLVMFunction >> addReturnAttribute: anAttribute [
	returnAttributes := returnAttributes copyWith: anAttribute
]

{ #category : #accessing }
LLVMFunction >> arguments [
	^ arguments
]

{ #category : #accessing }
LLVMFunction >> basicBlocks [
	^ basicBlocks
]

{ #category : #'as yet unclassified' }
LLVMFunction >> basicBlocksReplacedWith: replacement [
	basicBlocks := replacement
]

{ #category : #accessing }
LLVMFunction >> buildHandle [
	| context|
	context := functionType context.
	handle := ownerModule validHandle addFunction: name llvmNameForHandle type: functionType validHandle.
	handle setLinkage: (LinkageMap at: linkage).
	handle setVisibility: (VisibilityMap at: visibility).
	handle setDLLStorageClass: (DLLStorageMap at: dllStorageClass).
	self setHandleNamedMetadata.
	
	callingConvention ifNotNil: [ handle setFunctionCallingConvention: (CallingConventionMap at: callingConvention) ].
	personalityFunction ifNotNil: [ handle setPersonalityFunction: personalityFunction validHandle ].

	returnAttributes do: [ :attr |
		handle addAttribute: (context getOrCreateEnumAttributeHandleFor: attr) at: 0
	].

	"Set the arguments."
	arguments doWithIndex: [ :arg :index |
		arg setHandle: (handle getParam: index - 1).
		arg flags do: [ :attr |
			handle addAttribute: (context getOrCreateEnumAttributeHandleFor: attr) at: index
		]
	].

	functionAttributes do: [ :attr |
		handle addAttribute: (context getOrCreateEnumAttributeHandleFor: attr) at: -1
	].

	"Create the blocks."
	basicBlocks do: [ :each |
		each setHandle: (handle appendBasicBlockNamed: each name llvmNameForHandle inContext: functionType context)
	].

	"Create the instructions."
	basicBlocks do: [ :each |
		each buildInstructionHandles
	].
	
	"Fix the phi nodes."
	basicBlocks do: [ :each |
		each fixupInstructionHandles
	].

]

{ #category : #accessing }
LLVMFunction >> callingConvention [

	^ callingConvention
]

{ #category : #accessing }
LLVMFunction >> callingConvention: anObject [

	callingConvention := anObject
]

{ #category : #printing }
LLVMFunction >> fullPrintOn: aStream [
	self sanitizeNames.
	basicBlocks ifEmpty: [
		aStream << 'declare ' << linkage second << ' ' << visibility second << ' ' << dllStorageClass  second << callingConvention.
		returnAttributes do: [ :each |
			aStream space; nextPutAll: each
		].
	
		aStream << ' '; print: functionType returnType; << ' @'.
		self name llvmPrintNameOn: aStream.
		aStream << ' ( '.
		
		arguments doWithIndex: [ :arg :index |
			index > 1 ifTrue: [ aStream << ', ' ].
			arg printOnDeclaration: aStream
		].
	
		functionType isVarArg ifTrue: [ 
			arguments ifNotEmpty: [ aStream nextPutAll: ', ' ].
			aStream nextPutAll: '...' .
		].
		
		aStream << ' )'.
		functionAttributes do: [ :attr | aStream space; nextPutAll: attr ].
		^ self
	].

	aStream << 'define ' << linkage second << ' ' << visibility second << ' ' << dllStorageClass  second << callingConvention.
	returnAttributes do: [ :each |
		aStream space; nextPutAll: each
	].
	aStream << ' '; print: functionType returnType; << ' @'.
	self name llvmPrintNameOn: aStream.
	aStream << ' ( '.
	
	arguments doWithIndex: [ :arg :index |
			index > 1 ifTrue: [ aStream << ', ' ].
			arg printOnDefinition: aStream
	].

	functionType isVarArg ifTrue: [ 
		arguments ifNotEmpty: [ aStream nextPutAll: ', ' ].
		aStream nextPutAll: '...' .
	].

	aStream << ' )'.
	functionAttributes do: [ :attr | aStream space; nextPutAll: attr ].
	
	personalityFunction ifNotNil: [
		aStream nextPutAll: ' personality '; print: personalityFunction type; space; print: personalityFunction
	].
	gcStrategy ifNotNil: [ aStream << ' gc "' << gcStrategy << '"' ].
	self printComdatOn: aStream.
	self printMetadataOn: aStream.
	aStream nextPutAll: ' {'; lf.
	basicBlocks do: [ :bb | bb fullPrintOn: aStream ].
	aStream << '}'; lf.

	
]

{ #category : #accessing }
LLVMFunction >> functionAttributes [
	^ functionAttributes
]

{ #category : #accessing }
LLVMFunction >> functionAttributes: anObject [
	functionAttributes := anObject
]

{ #category : #accessing }
LLVMFunction >> functionType [
	^ functionType
]

{ #category : #accessing }
LLVMFunction >> gcStrategy [
	^ gcStrategy
]

{ #category : #accessing }
LLVMFunction >> gcStrategy: anObject [
	gcStrategy := anObject
]

{ #category : #initialization }
LLVMFunction >> generateLabelSymbol [
	| result |
	result := '__al' , labelSymbolGenerationCount asString.
	labelSymbolGenerationCount := labelSymbolGenerationCount + 1.
	^ result
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

{ #category : #testing }
LLVMFunction >> hasFunctionAttribute: attributeName [
	^ functionAttributes includes: attributeName
]

{ #category : #testing }
LLVMFunction >> hasReturnAttribute: attributeName [
	^ returnAttributes includes: attributeName
]

{ #category : #initialization }
LLVMFunction >> initialize [
	super initialize.
	basicBlocks := OrderedCollection new.
	callingConvention := #ccc.
	symbolGenerationCount := 0.
	labelSymbolGenerationCount := 0.
	hasArgumentNames := false.
	returnAttributes := #().
	functionAttributes := #().
	
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

{ #category : #'as yet unclassified' }
LLVMFunction >> isFunction [
	^ true
]

{ #category : #testing }
LLVMFunction >> isNoUnwind [
	^ self hasFunctionAttribute: #nounwind
]

{ #category : #accessing }
LLVMFunction >> personalityFunction [
	^ personalityFunction
]

{ #category : #accessing }
LLVMFunction >> personalityFunction: anObject [
	personalityFunction := anObject
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
LLVMFunction >> returnAttributes [
	^ returnAttributes
]

{ #category : #accessing }
LLVMFunction >> returnAttributes: anObject [
	returnAttributes := anObject
]

{ #category : #accessing }
LLVMFunction >> returnType [
	^ functionType returnType
]

{ #category : #printing }
LLVMFunction >> sanitizeNames [
	arguments do: [ :arg | arg name ifNil: [ arg name: self generateSymbol ] ].
	basicBlocks do: [ :bb |
		bb name ifNil: [ bb name: self generateLabelSymbol ].
		bb instructionsDo: [ :instruction  |
			instruction name ifNil: [
				instruction type isVoidTy ifFalse: [ 
					instruction name: self generateSymbol
				]
			]
		]
	]
]

Class {
	#name : #LLVMModule,
	#superclass : #LLVMObject,
	#instVars : [
		'valueSymbolTable',
		'name',
		'context',
		'symbolGenerationCount',
		'metadataSymbolGenerationCount',
		'structureSymbolTable',
		'metadataSymbolTable',
		'moduleLevelAssemblySources',
		'optimizationLevel'
	],
	#category : #'LLVM-IR'
}

{ #category : #'instance creation' }
LLVMModule class >> name: aName context: aContext [
	^ self basicNew initializeWithName: aName context: aContext
]

{ #category : #adding }
LLVMModule >> addGlobalValue: aGlobalValue [
	aGlobalValue name ifNil: [ aGlobalValue name: self generateSymbol ].
	valueSymbolTable at: aGlobalValue name ifPresent: [
		self error: 'Trying to override global value'
	] ifAbsentPut: [ aGlobalValue ]
]

{ #category : #adding }
LLVMModule >> addMetadata: aMetadata [
	aMetadata metadataName ifNil: [ aMetadata metadataName: self generateMetadataSymbol ].
	metadataSymbolTable at: aMetadata metadataName put: aMetadata.
	^ aMetadata
]

{ #category : #flags }
LLVMModule >> addModuleFlag: flagName value: flagValue behaviorOnCollision: flagBehavior [
	(self getOrCreateNamedMetadata: #'llvm.module.flags')
		addElement: (LLVMMDTuple for: self rawElements: { flagBehavior . flagName . flagValue})
]

{ #category : #adding }
LLVMModule >> addModuleLevelInlineAssembly: assemblySource [
	moduleLevelAssemblySources add: assemblySource
]

{ #category : #adding }
LLVMModule >> addNamedStructure: aStructureType [
	structureSymbolTable at: aStructureType name ifAbsentPut: [ aStructureType ]
]

{ #category : #writing }
LLVMModule >> asBinaryObject [
	| arguments elfFile elf |
	arguments := {
		'-O=' , optimizationLevel asString.
		'-filetype=obj' .
		'-o'. '-'.
		'-'.
	}.

	elfFile := (self runLLCWithArgumnents: arguments) asByteArray.
	elf := SAsmElfLoader loadFromStream: (SAsmBinaryReadStream on: (ReadStream on: elfFile)).
	^ elf asBinaryObject
]

{ #category : #printing }
LLVMModule >> asString [
	^ ByteString streamContents: [ :out | self fullPrintOn: out ]
]

{ #category : #accessing }
LLVMModule >> context [
	^ context
]

{ #category : #printing }
LLVMModule >> fullPrintOn: aStream [
	aStream << '; Module ' << name; lf.
	structureSymbolTable valuesDo: [ :value | value fullPrintOn: aStream. aStream lf ].
	moduleLevelAssemblySources do: [ :assembly | self printModuleLevelAssembly: assembly on: aStream ].
	valueSymbolTable valuesDo: [ :value | value fullPrintOn: aStream. aStream lf ].
	metadataSymbolTable valuesDo: [ :value | value fullPrintOn: aStream. aStream lf ].
]

{ #category : #initialization }
LLVMModule >> generateMetadataSymbol [
	| result |
	result := metadataSymbolGenerationCount asString.
	metadataSymbolGenerationCount := metadataSymbolGenerationCount + 1.
	^ result
]

{ #category : #initialization }
LLVMModule >> generateSymbol [
	| result |
	result := symbolGenerationCount asString.
	symbolGenerationCount := symbolGenerationCount + 1.
	^ result
]

{ #category : #intrinsic }
LLVMModule >> getDebugDeclareIntrinsic [
	| metadataTy |
	^ self getIntrinsic: #'llvm.dbg.declare' orCreateWithType: [
		metadataTy := context metadataTy.
		LLVMFunctionType get: context voidTy params: { metadataTy . metadataTy . metadataTy} isVarArg: false
	]
]

{ #category : #intrinsic }
LLVMModule >> getDebugValueIntrinsic [
	| metadataTy int64Ty |
	^ self getIntrinsic: #'llvm.dbg.value' orCreateWithType: [
		metadataTy := context metadataTy.
		int64Ty := context int64Ty.
		LLVMFunctionType get: context voidTy params: { metadataTy . int64Ty . metadataTy . metadataTy} isVarArg: false
	]
]

{ #category : #intrinsic }
LLVMModule >> getIntrinsic: intrinsicName orCreateWithType: typeBlock [
	^ valueSymbolTable at: intrinsicName ifAbsent: [ LLVMFunction createWithType: typeBlock value linkage: LLVMGlobalValue externalLinkage name: intrinsicName module: self  ]
]

{ #category : #'as yet unclassified' }
LLVMModule >> getNamedValue: name [
	^ valueSymbolTable at: name
]

{ #category : #adding }
LLVMModule >> getOrCreateNamedMetadata: aName [
	^ metadataSymbolTable at: aName ifAbsentPut: [ LLVMMDTuple new metadataName: aName ]
]

{ #category : #initialization }
LLVMModule >> initialize [
	super initialize.
	structureSymbolTable := LLVMOrderedDictionary new.
	valueSymbolTable := LLVMOrderedDictionary new.
	metadataSymbolTable := LLVMOrderedDictionary new.
	moduleLevelAssemblySources := OrderedCollection new.
	symbolGenerationCount := 0.
	metadataSymbolGenerationCount := 0.
	optimizationLevel := 0.
	
	
]

{ #category : #initialization }
LLVMModule >> initializeWithName: aName context: aContext [
	name := aName.
	context := aContext.
	self initialize
]

{ #category : #accessing }
LLVMModule >> name [
	^ name
]

{ #category : #accessing }
LLVMModule >> optimizationLevel [
	^ optimizationLevel
]

{ #category : #accessing }
LLVMModule >> optimizationLevel: anObject [
	optimizationLevel := anObject
]

{ #category : #printing }
LLVMModule >> printModuleLevelAssembly: assembly on: aStream [
	aStream << 'module asm '.
	assembly llvmPrintEscapedStringOn: aStream.
	aStream lf
]

{ #category : #writing }
LLVMModule >> runLLCWithArgumnents: arguments [
	| process output errorString stdout stderr |

	process := OSSUnixSubprocess new
		command: 'llc';
		arguments: arguments;
		redirectStdin;
		redirectStdout;
		redirectStderr;
		run.
	
	process stdinStream
		nextPutAll: (self asString);
		close.
	
	stdout := process stdoutStream.
	stderr := process stderrStream.
	output := ByteArray streamContents: [ :outputDest |
		errorString := ByteString streamContents: [ :errorOutput |
			process waitForExitPollingEvery: (Delay forMilliseconds: 50) doing: [
				outputDest nextPutAll: (stdout upToEnd asByteArray).
				errorOutput nextPutAll: stderr upToEnd
			]
		].
	].

	process closeAndCleanStreams.
	^ process isSuccess
		ifTrue: [ output ]
		ifFalse: [ self error: errorString ]

]

{ #category : #accessing }
LLVMModule >> valueSymbolTable [
	^ valueSymbolTable
]

{ #category : #printing }
LLVMModule >> writeAssemblyToFileNamed: aFileName [
	aFileName asFileReference writeStreamDo: [ :out |
		out truncate.
		self fullPrintOn: out
	]
]

{ #category : #writing }
LLVMModule >> writeExecutableToFileNamed: aFileName [
	self error: 'llvm to executable not yet implemented'
]

{ #category : #writing }
LLVMModule >> writeObjectToFileNamed: outputFileName [
	| arguments process outputString errorString |
	arguments := {
		'-O=' , optimizationLevel asString.
		'-filetype=obj' . '-o' .
		outputFileName . '-'.
	}.

	process := OSSUnixSubprocess new
		command: 'llc';
		arguments: arguments;
		redirectStdin;
		redirectStdout;
		redirectStderr;
		run.
	
	process stdinStream
		nextPutAll: (self asString);
		close.
	
	process waitForExit.
	outputString := process stdoutStream upToEndOfFile.
	errorString := process stdoutStream upToEndOfFile.
	process closeAndCleanStreams.
	process isSuccess
		ifTrue: [ ^ outputString ]
		ifFalse: [
			self error: errorString
	]
]

{ #category : #writing }
LLVMModule >> writeSharedToFileNamed: aFileName [
	self error: 'llvm to shared library not yet implemented'
]

{ #category : #printing }
LLVMModule >> writeTextToFileNamed: aFileName [
	aFileName asFileReference slvmAtomicWriteStreamDo: [ :out |
		self fullPrintOn: out
	]
]

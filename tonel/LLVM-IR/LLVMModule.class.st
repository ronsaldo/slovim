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
		'optimizationLevel',
		'targetTriple',
		'machineAttributes',
		'compilationPlugins',
		'linkerProgram',
		'llcProgram',
		'relocationModel',
		'linkerArguments'
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
	arguments := self llcFlags , {
		'-filetype=obj' .
		'-o'. '-'.
		'-'.
	}.

	elfFile := (self runLLCWithArguments: arguments) asByteArray.
	elf := SAsmElfLoader loadFromStream: (SAsmBinaryReadStream on: (ReadStream on: elfFile)).
	^ elf asBinaryObject
]

{ #category : #printing }
LLVMModule >> asString [
	^ ByteString streamContents: [ :out | self fullPrintOn: out ]
]

{ #category : #accessing }
LLVMModule >> compilationPlugins [
	^ compilationPlugins
]

{ #category : #accessing }
LLVMModule >> compilationPlugins: anObject [
	compilationPlugins := anObject
]

{ #category : #accessing }
LLVMModule >> context [
	^ context
]

{ #category : #printing }
LLVMModule >> fullPrintOn: aStream [
	aStream << '; Module ' << name; lf.
	targetTriple ifNotNil: [ aStream << 'target triple = "' << targetTriple << '"'; lf ].

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
	targetTriple := nil.
	
	
]

{ #category : #initialization }
LLVMModule >> initializeWithName: aName context: aContext [
	name := aName.
	context := aContext.
	self initialize
]

{ #category : #accessing }
LLVMModule >> linkerArguments [
	^ linkerArguments ifNil: [linkerArguments := #()]
]

{ #category : #accessing }
LLVMModule >> linkerArguments: aListOfFlags [
	linkerArguments := aListOfFlags
]

{ #category : #accessing }
LLVMModule >> linkerProgram [
	^ linkerProgram ifNil: [ linkerProgram := 'clang' ]
]

{ #category : #accessing }
LLVMModule >> linkerProgram: aLinkerProgram [
	linkerProgram := aLinkerProgram
]

{ #category : #writing }
LLVMModule >> llcFlags [
	| flags |
	flags := #().
	optimizationLevel ifNotNil: [ flags := { '-O=' , optimizationLevel asString} ].
	relocationModel ifNotNil: [ flags := flags , { '-relocation-model=' , relocationModel } ].
	(machineAttributes isNotNil and: [machineAttributes isNotEmpty]) ifTrue: [ 
		flags := flags , { '-mattr=' , machineAttributes }
	].
	compilationPlugins ifNotEmpty: [ 
		flags := flags , (compilationPlugins collect: [:pluginName |
			'-load=' , pluginName
		])
	].

	^ flags
]

{ #category : #accessing }
LLVMModule >> llcProgram [
	^ llcProgram ifNil: [llcProgram := 'llc']
]

{ #category : #accessing }
LLVMModule >> llcProgram: aProgramName [
	llcProgram := aProgramName
]

{ #category : #accessing }
LLVMModule >> machineAttributes [
	^ machineAttributes
]

{ #category : #accessing }
LLVMModule >> machineAttributes: anObject [
	machineAttributes := anObject
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

{ #category : #accessing }
LLVMModule >> relocationModel [
	^ relocationModel
]

{ #category : #accessing }
LLVMModule >> relocationModel: anObject [
	relocationModel := anObject
]

{ #category : #writing }
LLVMModule >> runCommand: command withArguments: arguments [
	^ self runCommand: command withArguments: arguments stdinInput: nil
]

{ #category : #writing }
LLVMModule >> runCommand: command withArguments: arguments stdinInput: stdinInput [
	| process output errorString stdout stderr |

	process := OSSUnixSubprocess new
		command: command;
		arguments: arguments;
		redirectStdin;
		redirectStdout;
		redirectStderr;
		run.
	
	stdinInput ifNotNil: [ 
		process stdinStream
			nextPutAll: stdinInput;
			close.
	].
	
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
		ifTrue: [
			errorString ifNotEmpty: [ self notify: errorString ].
			output
		]
		ifFalse: [ self error: errorString ]

]

{ #category : #writing }
LLVMModule >> runLLCWithArguments: arguments [
	^ self runCommand: self llcProgram withArguments: arguments stdinInput: self asString
]

{ #category : #writing }
LLVMModule >> runLinkerWithArguments: arguments [
	^ self runCommand: self linkerProgram withArguments: arguments
]

{ #category : #accessing }
LLVMModule >> targetTriple [
	^ targetTriple
]

{ #category : #accessing }
LLVMModule >> targetTriple: aTargetTriple [
	targetTriple := aTargetTriple
]

{ #category : #accessing }
LLVMModule >> valueSymbolTable [
	^ valueSymbolTable
]

{ #category : #writing }
LLVMModule >> withTemporaryObjectFileDo: aBlock [
	| tempFileReference tempFileName |
	tempFileReference := (FileSystem workingDirectory / ('temp_' , DateAndTime now asUnixTime asString , '.o')) asAbsolute.
	tempFileName := tempFileReference fullName.
	^ [
		
		self writeObjectToFileNamed: tempFileName.
		aBlock value: tempFileName
	] ensure: [
		tempFileReference exists ifTrue: [
			tempFileReference delete.
		].
	]
]

{ #category : #writing }
LLVMModule >> writeAssemblyToFileNamed: outputFileName [
	| arguments |
	arguments := self llcFlags , {
		'-filetype=asm' .
		'-o' . outputFileName .
		'-'.
	}.

	^ self runLLCWithArguments: arguments
]

{ #category : #writing }
LLVMModule >> writeExecutableToFileNamed: aFileName [
	^ self withTemporaryObjectFileDo: [ :temporaryObjectFile |
		| arguments |
		arguments := {
			'-o' . aFileName .
			temporaryObjectFile .
		} , self linkerArguments.
		
		self runLinkerWithArguments: arguments
	]
]

{ #category : #printing }
LLVMModule >> writeIRAssemblyToFileNamed: aFileName [
	aFileName asFileReference writeStreamDo: [ :out |
		out truncate.
		self fullPrintOn: out
	]
]

{ #category : #writing }
LLVMModule >> writeObjectToFileNamed: outputFileName [
	| arguments |
	arguments := self llcFlags , {
		'-filetype=obj' .
		'-o' . outputFileName .
		'-'.
	}.

	^ self runLLCWithArguments: arguments
]

{ #category : #writing }
LLVMModule >> writePluginToFileNamed: aFileName [
	^ self writeSharedToFileNamed: aFileName
]

{ #category : #writing }
LLVMModule >> writeSharedToFileNamed: aFileName [
	^ self withTemporaryObjectFileDo: [ :temporaryObjectFile |
		| arguments |
		arguments := {
			'-shared' .
			'-o' . aFileName .
			temporaryObjectFile .
		} , self linkerArguments.
		
		self runLinkerWithArguments: arguments
	]
]

{ #category : #printing }
LLVMModule >> writeTextToFileNamed: aFileName [
	aFileName asFileReference slvmAtomicWriteStreamDo: [ :out |
		self fullPrintOn: out
	]
]

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
		'cpu',
		'fpu',
		'floatAbiName',
		'machineAttributes',
		'compilationPlugins',
		'linkerProgram',
		'llcProgram',
		'relocationModel',
		'linkerArguments',
		'exceptionModel',
		'clangProgram',
		'linkerTargetTriple',
		'systemRoot'
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

{ #category : #writing }
LLVMModule >> clangFlags [
	| flags |
	flags := #().
	optimizationLevel ifNotNil: [ flags := { '-O' , optimizationLevel asString} ].
	flags := { '-target' . targetTriple }.
	cpu ifNotNil: [ flags := flags , { '-mcpu=' , cpu } ].
	fpu ifNotNil: [ flags := flags , { '-mfpu=' , fpu } ].
	floatAbiName ifNotNil: [ flags := flags , { '-mfloat-abi=' , floatAbiName } ].
	exceptionModel ifNotNil: [
		exceptionModel = #dwarf ifTrue: [ flags := flags , #('-fdwarf-exceptions') ].
		exceptionModel = #wineh ifTrue: [ flags := flags , #('-fseh-exceptions') ].
		exceptionModel = #sjlj ifTrue: [ flags := flags , #('-fsjlj-exceptions') ].
	].
	(machineAttributes isNotNil and: [machineAttributes isNotEmpty]) ifTrue: [ 
		flags := flags , machineAttributes
	].

	^ flags
]

{ #category : #accessing }
LLVMModule >> clangProgram [
	clangProgram ifNil: [ linkerProgram := OSEnvironment current at: 'CC' ifAbsent: [nil]].
	clangProgram ifNil: [
		(Smalltalk os isWin32 or: [ Smalltalk os isWin64 ]) ifTrue: [
			clangProgram := 'clang.exe'
		].
	
		clangProgram ifNil: [ clangProgram := 'clang' ].
		
		(self targetTriple isNotNil and: [ self targetTriple includesSubstring: 'wasm' ]) ifTrue: [
			clangProgram := 'emcc'
		]
	].

	^ clangProgram
]

{ #category : #accessing }
LLVMModule >> clangProgram: aProgramName [
	clangProgram := aProgramName
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

{ #category : #accessing }
LLVMModule >> cpu [
	^ cpu
]

{ #category : #accessing }
LLVMModule >> cpu: anObject [
	cpu := anObject
]

{ #category : #accessing }
LLVMModule >> exceptionModel [
	^ exceptionModel
]

{ #category : #accessing }
LLVMModule >> exceptionModel: anObject [
	exceptionModel := anObject
]

{ #category : #accessing }
LLVMModule >> floatAbiName [
	^ floatAbiName
]

{ #category : #accessing }
LLVMModule >> floatAbiName: anObject [
	floatAbiName := anObject
]

{ #category : #accessing }
LLVMModule >> fpu [
	^ fpu
]

{ #category : #accessing }
LLVMModule >> fpu: anObject [
	fpu := anObject
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
	^ valueSymbolTable at: intrinsicName ifAbsent: [
		self setKnownIntrinsicAttributes: (LLVMFunction createWithType: typeBlock value linkage: LLVMGlobalValue externalLinkage name: intrinsicName module: self)
	]
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
	linkerProgram ifNil: [ linkerProgram := OSEnvironment current at: 'CC' ifAbsent: [nil]].
	linkerProgram ifNil: [
		(Smalltalk os isWin32 or: [ Smalltalk os isWin64 ]) ifTrue: [
			linkerProgram := 'clang.exe'
		].
	
		linkerProgram ifNil: [ linkerProgram := 'clang' ].
		
		(self targetTriple isNotNil and: [ self targetTriple includesSubstring: 'wasm' ]) ifTrue: [
			linkerProgram := 'emcc'
		]
	].

	^ linkerProgram
]

{ #category : #accessing }
LLVMModule >> linkerProgram: aLinkerProgram [
	linkerProgram := aLinkerProgram
]

{ #category : #writing }
LLVMModule >> linkerTargetArguments [
	(self linkerProgram includesSubstring: 'clang') ifTrue: [
		| flags|
		flags := { '-target' . self validLinkerTargetTriple }.
		systemRoot ifNotNil: [ flags := flags , { '-sysroot=' , systemRoot} ].
		cpu ifNotNil: [ flags := flags , { '-mcpu=' , cpu } ].
		fpu ifNotNil: [ flags := flags , { '-mfpu=' , fpu } ].
		floatAbiName ifNotNil: [ flags := flags , { '-mfloat-abi=' , floatAbiName } ].
		^ flags	
	].
	^ #()
]

{ #category : #accessing }
LLVMModule >> linkerTargetTriple [
	^ linkerTargetTriple
]

{ #category : #accessing }
LLVMModule >> linkerTargetTriple: aTriple [
	linkerTargetTriple := aTriple
]

{ #category : #writing }
LLVMModule >> llcFlags [
	| flags |
	flags := #().
	optimizationLevel ifNotNil: [ flags := { '-O=' , optimizationLevel asString} ].
	relocationModel ifNotNil: [ flags := flags , { '-relocation-model=' , relocationModel } ].
	cpu ifNotNil: [ flags := flags , { '-mcpu=' , cpu } ].
	fpu ifNotNil: [ flags := flags , { '-mattr=' , fpu } ].
	floatAbiName ifNotNil: [ flags := flags , { '-float-abi=' , floatAbiName } ].
	exceptionModel ifNotNil: [ flags := flags , { '-exception-model=' , exceptionModel } ].
	(machineAttributes isNotNil and: [machineAttributes isNotEmpty]) ifTrue: [ 
		flags := flags , { '-mattr=' , machineAttributes }
	].
	flags := flags , #('--meabi=gnu').

	compilationPlugins ifNotEmpty: [ 
		flags := flags , (compilationPlugins collect: [:pluginName |
			'-load=' , pluginName
		])
	].

	^ flags
]

{ #category : #accessing }
LLVMModule >> llcProgram [
	llcProgram ifNil: [ llcProgram := OSEnvironment current at: 'LLC' ifAbsent: [nil] ].
	llcProgram ifNil: [
		(Smalltalk os isWin32 or: [ Smalltalk os isWin64 ]) ifTrue: [
			llcProgram := 'llc.exe'
		].
	
		llcProgram ifNil: [llcProgram := 'llc']
	].

	^ llcProgram
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
LLVMModule >> runClangWithArguments: arguments tempFileName: tempFileName [
	tempFileName writeStreamDo: [ :out |
		out truncate.
		self fullPrintOn: out
	].
	
	^ self runCommand: self clangProgram withArguments: arguments , { tempFileName fullName }
]

{ #category : #writing }
LLVMModule >> runCommand: command withArguments: arguments [
	| formattedCommand exitCode |
	formattedCommand := ByteString streamContents: [ :out |
		out nextPutAll: command.
		arguments do: [ :eachArgument |
			out space; nextPut: $"; nextPutAll: (eachArgument copyReplaceAll: '"' with: '\"'); nextPut: $".
		]
	].

	exitCode := LibC system: formattedCommand.
	exitCode ~= 0 ifTrue: [
		self error: 'Failed to invoke command: ' , formattedCommand 
	]
	
]

{ #category : #writing }
LLVMModule >> runLLCWithArguments: arguments tempFileName: tempFileName [
	tempFileName writeStreamDo: [ :out |
		out truncate.
		self fullPrintOn: out
	].
	
	^ self runCommand: self llcProgram withArguments: arguments , { tempFileName fullName }
]

{ #category : #writing }
LLVMModule >> runLinkerWithArguments: arguments [
	^ self runCommand: self linkerProgram withArguments: arguments
]

{ #category : #initialization }
LLVMModule >> setKnownIntrinsicAttributes: intrinsic [
	intrinsic functionAttributes: #(nounwind).
	^ intrinsic
]

{ #category : #accessing }
LLVMModule >> systemRoot [
	^ systemRoot
]

{ #category : #accessing }
LLVMModule >> systemRoot: anObject [
	systemRoot := anObject
]

{ #category : #accessing }
LLVMModule >> targetTriple [
	^ targetTriple
]

{ #category : #accessing }
LLVMModule >> targetTriple: aTargetTriple [
	targetTriple := aTargetTriple
]

{ #category : #writing }
LLVMModule >> useClangInsteadOfLLC [
	^ false "compilationPlugins isEmpty"
]

{ #category : #accessing }
LLVMModule >> validLinkerTargetTriple [
	^ linkerTargetTriple ifNil: [ targetTriple ]
]

{ #category : #accessing }
LLVMModule >> valueSymbolTable [
	^ valueSymbolTable
]

{ #category : #writing }
LLVMModule >> withTemporaryFileInDirectory: directory suffix: suffix do: aBlock [
	| tempFileReference |
	tempFileReference := (directory asFileReference / ('temp_' , DateAndTime now asUnixTime asString , suffix)) asAbsolute.
	^ [
		aBlock value: tempFileReference
	] ensure: [
		tempFileReference exists ifTrue: [
			tempFileReference delete.
		].
	]
]

{ #category : #writing }
LLVMModule >> withTemporaryFileInSameDirectoryOf: file suffix: suffix do: aBlock [
	^ self withTemporaryFileInDirectory: file asFileReference parent suffix: suffix do: aBlock
]

{ #category : #writing }
LLVMModule >> withTemporaryFileWithSuffix: suffix do: aBlock [
	^ self withTemporaryFileInDirectory: FileSystem workingDirectory parent suffix: suffix do: aBlock
]

{ #category : #writing }
LLVMModule >> writeAssemblyToFileNamed: outputFileRef [
	| arguments |
	self useClangInsteadOfLLC ifTrue: [
		arguments := self clangFlags , {
			'-S' .
			'-o' . outputFileRef fullName.
		}.

		^ self runClangWithArguments: arguments tempFileName: (outputFileRef fullName , '.ll') asFileReference asAbsolute
	] ifFalse: [ 
		arguments := self llcFlags , {
			'-filetype=asm' .
			'-o' . outputFileRef fullName.
		}.

		^ self runLLCWithArguments: arguments tempFileName: (outputFileRef fullName , '.ll') asFileReference asAbsolute
	].

]

{ #category : #writing }
LLVMModule >> writeExecutableToFileNamed: outputFileName [
	| outputFileRef objectFile arguments |
	outputFileRef := outputFileName asFileReference asAbsolute.
	objectFile := outputFileRef fullName , '.o'.
	self writeObjectToFileNamed: objectFile.

	arguments := self linkerTargetArguments , {
		'-o' . outputFileRef fullName.
		objectFile.
	} , self linkerArguments.
	
	^ self runLinkerWithArguments: arguments

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
	| arguments outputFileRef |
	self useClangInsteadOfLLC ifTrue: [
		outputFileRef := outputFileName asFileReference asAbsolute.
		arguments := self clangFlags , {
			'-c' .
			'-o' . outputFileRef fullName.
		}.

		^ self runClangWithArguments: arguments tempFileName: (outputFileRef fullName , '.ll') asFileReference asAbsolute
	] ifFalse: [
		outputFileRef := outputFileName asFileReference asAbsolute.
		arguments := self llcFlags , {
			'-filetype=obj' .
			'-o' . outputFileRef fullName.
		}.

		^ self runLLCWithArguments: arguments tempFileName: (outputFileRef fullName , '.ll') asFileReference asAbsolute
	]

]

{ #category : #writing }
LLVMModule >> writePluginToFileNamed: aFileName [
	^ self writeSharedToFileNamed: aFileName
]

{ #category : #writing }
LLVMModule >> writeSharedToFileNamed: outputFileName [
	| outputFileRef objectFile arguments |
	outputFileRef := outputFileName asFileReference asAbsolute.
	objectFile := outputFileRef fullName , '.o'.
	self writeObjectToFileNamed: objectFile.

	arguments := self linkerTargetArguments , {
		'-shared'.
		'-o' . outputFileRef fullName.
		objectFile fullName.
	} , self linkerArguments.
		
	^ self runLinkerWithArguments: arguments

]

{ #category : #printing }
LLVMModule >> writeTextToFileNamed: aFileName [
	aFileName asFileReference slvmAtomicWriteStreamDo: [ :out |
		self fullPrintOn: out
	]
]

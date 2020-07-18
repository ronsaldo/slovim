Class {
	#name : #SLVMCompilationTarget,
	#superclass : #SLVMObject,
	#instVars : [
		'types',
		'emittingDebugInformation',
		'targetTriple',
		'linkerTargetTriple'
	],
	#classVars : [
		'LandingPadSelectorRegisterIndexMap',
		'LandingPadStructurePointerIndexMap'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #'class initialization' }
SLVMCompilationTarget class >> initialize [
	LandingPadStructurePointerIndexMap := Dictionary newFromPairs: #(
		x86_64 0
		i686 0
	).
	LandingPadSelectorRegisterIndexMap := Dictionary newFromPairs: #(
		x86_64 1
		i686 2
	).
]

{ #category : #accessing }
SLVMCompilationTarget >> abiName [
	^ nil
]

{ #category : #types }
SLVMCompilationTarget >> anonStructure: slots [
	^ types anonStructure: slots
]

{ #category : #types }
SLVMCompilationTarget >> arrayOf: elementType size: size [
	^ types arrayOf: elementType size: size
]

{ #category : #types }
SLVMCompilationTarget >> bool [
	^ types bool
]

{ #category : #accessing }
SLVMCompilationTarget >> callingConventionDescriptionNamed: callingConventionName [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMCompilationTarget >> canonicalArchitecture [
	^ self architecture
]

{ #category : #accessing }
SLVMCompilationTarget >> canonicalName [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMCompilationTarget >> canonicalOperatingSystemName [
	^ self operatingSystemName
]

{ #category : #types }
SLVMCompilationTarget >> char [
	^ types char
]

{ #category : #initialization }
SLVMCompilationTarget >> createTargetTypes [
	self subclassResponsibility
]

{ #category : #types }
SLVMCompilationTarget >> depthTexture2D [
	^ types depthTexture2D
]

{ #category : #types }
SLVMCompilationTarget >> depthTexture2DArray [
	^ types depthTexture2DArray
]

{ #category : #types }
SLVMCompilationTarget >> depthTextureCube [
	^ types depthTextureCube
]

{ #category : #types }
SLVMCompilationTarget >> depthTextureCubeArray [
	^ types depthTextureCubeArray
]

{ #category : #types }
SLVMCompilationTarget >> double [
	^ types double
]

{ #category : #types }
SLVMCompilationTarget >> doubleAlign4 [
	^ types doubleAlign4
]

{ #category : #types }
SLVMCompilationTarget >> doubleAlign8 [
	^ types doubleAlign8
]

{ #category : #types }
SLVMCompilationTarget >> dynamicObjectType [
	^ types dynamicObjectType
]

{ #category : #accessing }
SLVMCompilationTarget >> emittingDebugInformation [
	^ emittingDebugInformation
]

{ #category : #accessing }
SLVMCompilationTarget >> emittingDebugInformation: anObject [
	emittingDebugInformation := anObject
]

{ #category : #types }
SLVMCompilationTarget >> float [
	^ types float
]

{ #category : #types }
SLVMCompilationTarget >> float32 [
	^ types float32
]

{ #category : #types }
SLVMCompilationTarget >> float64 [
	^ types float64
]

{ #category : #convenience }
SLVMCompilationTarget >> generateLowLevelModule: aModule [
	^ self lowLevelCodeGeneratorClass translateModule: aModule
]

{ #category : #testing }
SLVMCompilationTarget >> hasArmEhAbi [
	^ false
]

{ #category : #initialization }
SLVMCompilationTarget >> initialize [
	super initialize.
	emittingDebugInformation := false.
	types := self createTargetTypes
]

{ #category : #types }
SLVMCompilationTarget >> int [
	^ types int
]

{ #category : #types }
SLVMCompilationTarget >> int16 [
	^ types int16
]

{ #category : #types }
SLVMCompilationTarget >> int32 [
	^ types int32
]

{ #category : #types }
SLVMCompilationTarget >> int64 [
	^ types int64
]

{ #category : #types }
SLVMCompilationTarget >> int8 [
	^ types int8
]

{ #category : #types }
SLVMCompilationTarget >> intPointer [
	^ types intPointer
]

{ #category : #testing }
SLVMCompilationTarget >> isARM [
	^ self isARM32 or: [ self isARM64 ]
]

{ #category : #testing }
SLVMCompilationTarget >> isARM32 [
	^ false
]

{ #category : #testing }
SLVMCompilationTarget >> isARM64 [
	^ false
]

{ #category : #testing }
SLVMCompilationTarget >> isBigEndian [
	^ self isLittleEndian not
]

{ #category : #testing }
SLVMCompilationTarget >> isCurrentImage [
	^ false
]

{ #category : #testing }
SLVMCompilationTarget >> isEmbeddedPAL [
	^ false
]

{ #category : #testing }
SLVMCompilationTarget >> isFreeBSD [
	^ self operatingSystemName = #freebsd
]

{ #category : #testing }
SLVMCompilationTarget >> isLLVMCompilationTarget [
	^ false
]

{ #category : #testing }
SLVMCompilationTarget >> isLinux [
	^ self operatingSystemName = #linux
]

{ #category : #testing }
SLVMCompilationTarget >> isLittleEndian [
	^ true
]

{ #category : #testing }
SLVMCompilationTarget >> isMIPS [
	^ false
]

{ #category : #testing }
SLVMCompilationTarget >> isNoOperatingSystem [
	^ self operatingSystemName = #none
]

{ #category : #testing }
SLVMCompilationTarget >> isNullOS [
	^ false
]

{ #category : #testing }
SLVMCompilationTarget >> isOSX [
	^ self operatingSystemName = #osx
]

{ #category : #testing }
SLVMCompilationTarget >> isWebAssembly [
	^ false
]

{ #category : #testing }
SLVMCompilationTarget >> isWindows [
	^ #windows = self operatingSystemName
]

{ #category : #testing }
SLVMCompilationTarget >> isX86 [
	^ self isX86_32 or: [ self isX86_64 ]
]

{ #category : #testing }
SLVMCompilationTarget >> isX86_32 [
	^ false
]

{ #category : #testing }
SLVMCompilationTarget >> isX86_64 [
	^ false
]

{ #category : #'as yet unclassified' }
SLVMCompilationTarget >> landingPadSelectorRegisterIndex [
	^ LandingPadSelectorRegisterIndexMap at: self canonicalArchitecture ifAbsent: [ 1 ]
]

{ #category : #'as yet unclassified' }
SLVMCompilationTarget >> landingPadStructurePointerRegisterIndex [
	^ LandingPadStructurePointerIndexMap at: self canonicalArchitecture ifAbsent: [ 0 ]
]

{ #category : #accessing }
SLVMCompilationTarget >> linkerTargetTriple [
	^ linkerTargetTriple ifNil: [linkerTargetTriple := ByteString streamContents: [ :out |
			out nextPutAll: self canonicalArchitecture.
		
			self systemVendor ifNotNil: [ :vendor |
				vendor ~= #unknown ifTrue: [ 
					out nextPut: $-; nextPutAll: vendor
				].
			].

			self canonicalOperatingSystemName ifNotNil: [ :system |
				system ~= #unknown ifTrue: [ 
					out nextPut: $-; nextPutAll: system
				].
			].

			self abiName ifNotNil: [ :abi |
				abi ~= #unknown ifTrue: [ 
					out nextPut: $-; nextPutAll: abi
				]
			].
		]
	].
]

{ #category : #accessing }
SLVMCompilationTarget >> lowLevelCodeGeneratorClass [
	self subclassResponsibility
]

{ #category : #types }
SLVMCompilationTarget >> matrix: aBaseType rows: numRows columns: numColumns [
	^ types matrix: aBaseType rows: numRows columns: numColumns
]

{ #category : #testing }
SLVMCompilationTarget >> needsSlotForGOTPointer [
	<compileTime>
	^ false
]

{ #category : #convenience }
SLVMCompilationTarget >> newModule [
	^ SLVMModule new compilationTarget: self; yourself
]

{ #category : #accessing }
SLVMCompilationTarget >> objectModel [
	^ types objectModel
]

{ #category : #accessing }
SLVMCompilationTarget >> objectModel: anObject [
	types objectModel: anObject
]

{ #category : #accessing }
SLVMCompilationTarget >> operatingSystemName [
	^ self subclassResponsibility
]

{ #category : #accessing }
SLVMCompilationTarget >> pointerAlignment [
	^ types pointerAlignment
]

{ #category : #accessing }
SLVMCompilationTarget >> pointerSize [
	^ types pointerSize
]

{ #category : #types }
SLVMCompilationTarget >> pointerTo: baseType [
	^ types pointerTo: baseType
]

{ #category : #types }
SLVMCompilationTarget >> pointerTo: baseType storage: storageClass [
	^ types pointerTo: baseType storage: storageClass
]

{ #category : #accessing }
SLVMCompilationTarget >> referenceAlignment [
	^ types referenceAlignment
]

{ #category : #accessing }
SLVMCompilationTarget >> referenceSize [
	^ types referenceSize
]

{ #category : #types }
SLVMCompilationTarget >> sampler [
	^ types sampler
]

{ #category : #'as yet unclassified' }
SLVMCompilationTarget >> sharedObjectsAreAlsoImports [
	^ self isWindows not
]

{ #category : #types }
SLVMCompilationTarget >> short [
	^ types short
]

{ #category : #accessing }
SLVMCompilationTarget >> subarchitecture [
	^ nil
]

{ #category : #testing }
SLVMCompilationTarget >> supportsLocalAddressForThisContext [
	^ false
]

{ #category : #accessing }
SLVMCompilationTarget >> systemVendor [
	^ nil
]

{ #category : #accessing }
SLVMCompilationTarget >> targetTriple [
	^ targetTriple ifNil: [targetTriple := ByteString streamContents: [ :out |
			out nextPutAll: self canonicalArchitecture.
			self subarchitecture ifNotNil: [ :subarch |
				out nextPutAll: subarch
			].
		
			self systemVendor ifNil: [
				out nextPutAll: '-unknown'
			] ifNotNil: [ :vendor |
				out nextPut: $-; nextPutAll: vendor
			].

			self canonicalOperatingSystemName ifNil: [
				out nextPutAll: '-none'
			] ifNotNil: [ :system |
				out nextPut: $-; nextPutAll: system
			].

			self abiName ifNil: [
				out nextPutAll: '-unknown'
			] ifNotNil: [ :abi |
				out nextPut: $-; nextPutAll: abi
			].
		]
	].
]

{ #category : #types }
SLVMCompilationTarget >> texture1D [
	^ types texture1D
]

{ #category : #types }
SLVMCompilationTarget >> texture1DArray [
	^ types texture1DArray
]

{ #category : #types }
SLVMCompilationTarget >> texture2D [
	^ types texture2D
]

{ #category : #types }
SLVMCompilationTarget >> texture2DArray [
	^ types texture2DArray
]

{ #category : #types }
SLVMCompilationTarget >> texture3D [
	^ types texture3D
]

{ #category : #types }
SLVMCompilationTarget >> texture3DArray [
	^ types texture3DArray
]

{ #category : #types }
SLVMCompilationTarget >> textureCube [
	^ types textureCube
]

{ #category : #types }
SLVMCompilationTarget >> textureCubeArray [
	^ types textureCubeArray
]

{ #category : #types }
SLVMCompilationTarget >> textureType: baseTextureType versionWithFormat: requiredFormat [
	^ types textureType: baseTextureType versionWithFormat: requiredFormat
]

{ #category : #types }
SLVMCompilationTarget >> types [
	^ types
]

{ #category : #types }
SLVMCompilationTarget >> types: aSetOfTypes [
	types := aSetOfTypes
]

{ #category : #types }
SLVMCompilationTarget >> uchar [
	^ types uchar
]

{ #category : #types }
SLVMCompilationTarget >> uint [
	^ types uint
]

{ #category : #types }
SLVMCompilationTarget >> uint16 [
	^ types uint16
]

{ #category : #types }
SLVMCompilationTarget >> uint32 [
	^ types uint32
]

{ #category : #types }
SLVMCompilationTarget >> uint64 [
	^ types uint64
]

{ #category : #types }
SLVMCompilationTarget >> uint8 [
	^ types uint8
]

{ #category : #types }
SLVMCompilationTarget >> uintPointer [
	^ types uintPointer
]

{ #category : #types }
SLVMCompilationTarget >> ulong [
	^ types ulong
]

{ #category : #types }
SLVMCompilationTarget >> ushort [
	^ types ushort
]

{ #category : #types }
SLVMCompilationTarget >> vector: baseType elements: elements [
	^ types vector: baseType elements: elements
]

{ #category : #types }
SLVMCompilationTarget >> void [
	^ types void
]

{ #category : #types }
SLVMCompilationTarget >> voidPointerPointerType [
	^ types voidPointerPointerType
]

{ #category : #types }
SLVMCompilationTarget >> voidPointerType [
	^ types voidPointerType
]

{ #category : #initialization }
SLVMCompilationTarget >> withDebugInformation [
	self emittingDebugInformation: true
]

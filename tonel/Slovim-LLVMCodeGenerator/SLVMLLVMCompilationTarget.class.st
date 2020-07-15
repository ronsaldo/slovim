Class {
	#name : #SLVMLLVMCompilationTarget,
	#superclass : #SLVMCompilationTarget,
	#instVars : [
		'architecture',
		'subarchitecture',
		'canonicalArchitecture',
		'pointerSize',
		'operatingSystemName',
		'cpu',
		'fpu',
		'abiName',
		'floatAbiName',
		'systemVendor',
		'machineAttributes',
		'compilationPlugins',
		'relocationModel',
		'exceptionModel'
	],
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #construction }
SLVMLLVMCompilationTarget class >> arm [
	^ self basicNew
		arm;
		pointerSize: 4;
		initialize;
		yourself
]

{ #category : #construction }
SLVMLLVMCompilationTarget class >> arm64 [
	^ self basicNew
		arm64;
		pointerSize: 8;
		initialize;
		yourself
]

{ #category : #construction }
SLVMLLVMCompilationTarget class >> armv5 [
	^ self basicNew
		armv5;
		pointerSize: 4;
		initialize;
		yourself
]

{ #category : #construction }
SLVMLLVMCompilationTarget class >> armv6 [
	^ self basicNew
		armv6;
		pointerSize: 4;
		initialize;
		yourself
]

{ #category : #construction }
SLVMLLVMCompilationTarget class >> armv6m [
	^ self basicNew
		armv6m;
		pointerSize: 4;
		initialize;
		yourself
]

{ #category : #construction }
SLVMLLVMCompilationTarget class >> armv7 [
	^ self basicNew
		armv7;
		pointerSize: 4;
		initialize;
		yourself
]

{ #category : #construction }
SLVMLLVMCompilationTarget class >> armv7a [
	^ self basicNew
		armv7a;
		pointerSize: 4;
		initialize;
		yourself
]

{ #category : #construction }
SLVMLLVMCompilationTarget class >> armv7m [
	^ self basicNew
		armv7m;
		pointerSize: 4;
		initialize;
		yourself
]

{ #category : #construction }
SLVMLLVMCompilationTarget class >> mipsel [
	^ self basicNew
		mipsel;
		pointerSize: 4;
		initialize;
		yourself
]

{ #category : #construction }
SLVMLLVMCompilationTarget class >> webAssembly [
	^ self webAssembly32
]

{ #category : #construction }
SLVMLLVMCompilationTarget class >> webAssembly32 [
	^ self basicNew
		webAssembly32;
		pointerSize: 4;
		initialize;
		yourself
]

{ #category : #construction }
SLVMLLVMCompilationTarget class >> webAssembly64 [
	^ self basicNew
		webAssembly32;
		pointerSize: 8;
		initialize;
		yourself
]

{ #category : #construction }
SLVMLLVMCompilationTarget class >> x86 [
	^ self basicNew
		x86;
		pointerSize: 4;
		initialize;
		yourself
]

{ #category : #construction }
SLVMLLVMCompilationTarget class >> x86_64 [
	^ self basicNew
		x86_64;
		pointerSize: 8;
		initialize;
		yourself
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> abiName [
	^ abiName
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> abiName: anObject [
	abiName := anObject
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> applyABI [
	(#(x86 x86_64) includes: self architecture) ifTrue: [ 
		self isWin32 ifTrue: [ ^ self abiName: #msvc ].
		self isLinux ifTrue: [ ^ self abiName: #gnu ].
		self isOSX ifTrue: [ ^ self abiName: #macho ].
		^ self abiName: #elf
	].

	(self architecture beginsWith: #arm) ifTrue: [
		self isLinux ifTrue: [ ^ self floatAbiName: #hard; abiName: #gnueabihf ].
		^ self abiName: #eabi
	].

	(self architecture beginsWith: #mips) ifTrue: [
		self isLinux ifTrue: [ ^ self abiName: #gnu ].
	].

	self abiName: nil
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> applyDefaultVendor [
	systemVendor ifNotNil: [ ^ nil ].
	
	(#(x86 x86_64) includes: self architecture) ifTrue: [ 
		^ self systemVendor: #pc
	].

	self systemVendor: #unknown

]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> applyExceptionHandlingModel [
	exceptionModel := #dwarf.
	(architecture beginsWith: #arm) ifTrue: [
		exceptionModel := #arm.
		^ self.
	].

	self isWin32 ifTrue: [ 
		exceptionModel := #wineh
	].
	self isWebAssembly ifTrue: [ 
		exceptionModel := #wasm
	]
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> architecture [
	^ architecture
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> architecture: aName [
	architecture := aName.
	canonicalArchitecture := aName.
	self
		applyDefaultVendor;
		applyABI;
		applyExceptionHandlingModel
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> architecture: aName subarchitecture: subArchitectureName [
	architecture := aName.
	subarchitecture := subArchitectureName.
	canonicalArchitecture := aName.
	self
		applyDefaultVendor;
		applyABI;
		applyExceptionHandlingModel
]

{ #category : #architectures }
SLVMLLVMCompilationTarget >> arm [
	self
		architecture: #arm
]

{ #category : #architectures }
SLVMLLVMCompilationTarget >> arm64 [
	self
		architecture: #arm64
]

{ #category : #architectures }
SLVMLLVMCompilationTarget >> armv5 [
	self
		architecture: #arm subarchitecture: #v5
]

{ #category : #architectures }
SLVMLLVMCompilationTarget >> armv6 [
	self
		architecture: #arm subarchitecture: #v6
]

{ #category : #architectures }
SLVMLLVMCompilationTarget >> armv6m [
	self
		architecture: #arm subarchitecture: #v6m
]

{ #category : #architectures }
SLVMLLVMCompilationTarget >> armv7 [
	self
		architecture: #arm subarchitecture: #v7
]

{ #category : #architectures }
SLVMLLVMCompilationTarget >> armv7a [
	self
		architecture: #arm subarchitecture: #v7a
]

{ #category : #architectures }
SLVMLLVMCompilationTarget >> armv7m [
	self
		architecture: #armv subarchitecture: #v7m
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> canonicalArchitecture [
	^ canonicalArchitecture
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> canonicalArchitecture: anObject [
	canonicalArchitecture := anObject
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> compilationPlugins [
	^ compilationPlugins
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> compilationPlugins: anObject [
	compilationPlugins := anObject
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> cpu [
	^ cpu
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> cpu: anObject [
	cpu := anObject
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> createTargetTypes [
	^ pointerSize = 4
		ifTrue: [ SLVM32BitsPointerCompilationTargetTypes new ]
		ifFalse: [ SLVM64BitsPointerCompilationTargetTypes new ]
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> exceptionModel [
	^ exceptionModel
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> exceptionModel: anObject [
	exceptionModel := anObject
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> floatAbiName [
	^ floatAbiName
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> floatAbiName: anObject [
	floatAbiName := anObject
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> fpu [
	^ fpu
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> fpu: anObject [
	fpu := anObject
]

{ #category : #convenience }
SLVMLLVMCompilationTarget >> generateLowLevelModule: aModule [
	^ SLVMLLVMCodeGenerator new target: self; translateModule: aModule
]

{ #category : #convenience }
SLVMLLVMCompilationTarget >> generateLowLevelModule: aModule optimizationLevel: anOptimizationLevel [
	^ SLVMLLVMCodeGenerator new
		target: self;
		optimizationLevel: anOptimizationLevel;
		translateModule: aModule
]

{ #category : #testing }
SLVMLLVMCompilationTarget >> hasArmEhAbi [
	^ architecture beginsWith: #arm
]

{ #category : #initialization }
SLVMLLVMCompilationTarget >> initialize [
	super initialize.
	compilationPlugins := #().
	self isWebAssembly ifTrue: [
		self operatingSystemName: #wasi.
	] ifFalse: [ 
		self operatingSystemName: Smalltalk os slvmOperatingSystemName.
	].

]

{ #category : #testing }
SLVMLLVMCompilationTarget >> isARM32 [
	^ (architecture beginsWith: #arm) and: [ (architecture beginsWith: #arm64) not ]
]

{ #category : #testing }
SLVMLLVMCompilationTarget >> isARM64 [ 
	^ architecture beginsWith: #arm64
]

{ #category : #testing }
SLVMLLVMCompilationTarget >> isLLVMCompilationTarget [
	^ true
]

{ #category : #testing }
SLVMLLVMCompilationTarget >> isMIPS [
	^ architecture beginsWith: #mips
]

{ #category : #testing }
SLVMLLVMCompilationTarget >> isWebAssembly [
	^ architecture beginsWith: #wasm
]

{ #category : #testing }
SLVMLLVMCompilationTarget >> isX86_32 [
	^ architecture = #x86
]

{ #category : #testing }
SLVMLLVMCompilationTarget >> isX86_64 [
	^ architecture = #x86_64
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> machineAttributes [
	^ machineAttributes
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> machineAttributes: anObject [
	machineAttributes := anObject
]

{ #category : #architectures }
SLVMLLVMCompilationTarget >> mipsel [
	self
		architecture: #mipsel
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> operatingSystemName [
	^ operatingSystemName
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> operatingSystemName: aName [
	operatingSystemName := aName.
	self applyABI; applyDefaultVendor; applyExceptionHandlingModel
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> pointerSize [
	^ pointerSize
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> pointerSize: anObject [
	pointerSize := anObject
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> relocationModel [
	^ relocationModel
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> relocationModel: aRelocationModel [
	relocationModel := aRelocationModel
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> subarchitecture [
	^ subarchitecture
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> subarchitecture: anObject [
	subarchitecture := anObject
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> supportsLocalAddressForThisContext [
	^ #(x86_64) includes: self architecture
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> systemVendor [
	^ systemVendor
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> systemVendor: anObject [
	systemVendor := anObject
]

{ #category : #architectures }
SLVMLLVMCompilationTarget >> webAssembly32 [
	self
		architecture: #wasm32;
		canonicalArchitecture: #wasm32
]

{ #category : #architectures }
SLVMLLVMCompilationTarget >> webAssembly64 [
	self
		architecture: #wasm64;
		canonicalArchitecture: #wasm64
]

{ #category : #initialization }
SLVMLLVMCompilationTarget >> withPositionIndependentCode [
	relocationModel := #pic
]

{ #category : #architectures }
SLVMLLVMCompilationTarget >> x86 [
	self
		architecture: #x86;
		canonicalArchitecture: #i686
]

{ #category : #architectures }
SLVMLLVMCompilationTarget >> x86_64 [
	self architecture: #x86_64
]

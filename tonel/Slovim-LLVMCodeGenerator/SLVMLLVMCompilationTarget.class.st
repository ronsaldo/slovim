Class {
	#name : #SLVMLLVMCompilationTarget,
	#superclass : #SLVMCompilationTarget,
	#instVars : [
		'architecture',
		'subarchitecture',
		'canonicalArchitecture',
		'pointerSize',
		'operatingSystemName',
		'abiName',
		'systemVendor',
		'machineAttributes'
	],
	#category : #'Slovim-LLVMCodeGenerator'
}

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
		self isWin32 ifTrue: [ ^ self abiName: #coff ].
		self isLinux ifTrue: [ ^ self abiName: #gnu ].
		self isOSX ifTrue: [ ^ self abiName: #macho ].
		^ self abiName: #elf
	].

	self abiName: nil
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> applyDefaultVendor [
	(#(x86 x86_64) includes: self architecture) ifTrue: [ 
		^ self systemVendor: #pc
	].

	self systemVendor: nil
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
		applyABI
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
SLVMLLVMCompilationTarget >> createTargetTypes [
	^ pointerSize = 4
		ifTrue: [ SLVM32BitsPointerCompilationTargetTypes new ]
		ifFalse: [ SLVM64BitsPointerCompilationTargetTypes new ]
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

{ #category : #initialization }
SLVMLLVMCompilationTarget >> initialize [
	super initialize.
	self operatingSystemName: #linux
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> machineAttributes [
	^ machineAttributes
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> machineAttributes: anObject [
	machineAttributes := anObject
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> operatingSystemName [
	^ operatingSystemName
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> operatingSystemName: aName [
	operatingSystemName := aName.
	self applyABI
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
SLVMLLVMCompilationTarget >> subarchitecture [
	^ subarchitecture
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> subarchitecture: anObject [
	subarchitecture := anObject
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> systemVendor [
	^ systemVendor
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> systemVendor: anObject [
	systemVendor := anObject
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> x86 [
	self
		architecture: #x86;
		canonicalArchitecture: #i686
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> x86_64 [
	self architecture: #x86_64
]

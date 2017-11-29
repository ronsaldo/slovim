Class {
	#name : #SLVMCompilationTarget,
	#superclass : #SLVMObject,
	#instVars : [
		'types',
		'emittingDebugInformation'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #types }
SLVMCompilationTarget >> bool [
	^ types bool
]

{ #category : #accessing }
SLVMCompilationTarget >> callingConventionDescriptionNamed: callingConventionName [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMCompilationTarget >> canonicalName [
	self subclassResponsibility
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

{ #category : #convenience }
SLVMCompilationTarget >> generateLowLevelModule: aModule [
	^ self lowLevelCodeGeneratorClass translateModule: aModule
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

{ #category : #testing }
SLVMCompilationTarget >> isBigEndian [
	^ self isLittleEndian not
]

{ #category : #testing }
SLVMCompilationTarget >> isCurrentImage [
	^ false
]

{ #category : #testing }
SLVMCompilationTarget >> isLittleEndian [
	^ true
]

{ #category : #accessing }
SLVMCompilationTarget >> lowLevelCodeGeneratorClass [
	self subclassResponsibility
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
SLVMCompilationTarget >> objectHeaderSize [
	^ objectModel objectHeaderSize
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
SLVMCompilationTarget >> short [
	^ types short
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
SLVMCompilationTarget >> ulong [
	^ types ulong
]

{ #category : #types }
SLVMCompilationTarget >> ushort [
	^ types ushort
]

{ #category : #types }
SLVMCompilationTarget >> void [
	^ types void
]

{ #category : #types }
SLVMCompilationTarget >> voidPointerType [
	^ types voidPointerType
]

{ #category : #initialization }
SLVMCompilationTarget >> withDebugInformation [
	self emittingDebugInformation: true
]

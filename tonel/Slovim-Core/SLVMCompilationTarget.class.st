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
SLVMCompilationTarget >> voidPointerType [
	^ types voidPointerType
]

{ #category : #initialization }
SLVMCompilationTarget >> withDebugInformation [
	self emittingDebugInformation: true
]

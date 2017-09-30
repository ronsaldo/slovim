Class {
	#name : #SLVMCompilationTarget,
	#superclass : #SLVMObject,
	#instVars : [
		'dynamicObjectType',
		'voidPointerType',
		'objectModel',
		'emittingDebugInformation'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #types }
SLVMCompilationTarget >> bool [
	^ SLVMType boolType
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
	^ SLVMType charType
]

{ #category : #types }
SLVMCompilationTarget >> double [
	^ self subclassResponsibility
]

{ #category : #types }
SLVMCompilationTarget >> doubleAlign4 [
	^ SLVMType doubleAlign4Type
]

{ #category : #types }
SLVMCompilationTarget >> doubleAlign8 [
	^ SLVMType doubleAlign8Type
]

{ #category : #accessing }
SLVMCompilationTarget >> dynamicObjectType [
	^ dynamicObjectType ifNil: [ dynamicObjectType := SLVMDynamicObjectType new size: self pointerSize ]
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
	^ SLVMType floatType
]

{ #category : #convenience }
SLVMCompilationTarget >> generateLowLevelModule: aModule [
	^ self lowLevelCodeGeneratorClass translateModule: aModule
]

{ #category : #initialization }
SLVMCompilationTarget >> initialize [
	super initialize.
	objectModel := SLVMNativeRuntimeObjectModel new target: self.
	emittingDebugInformation := false.
]

{ #category : #types }
SLVMCompilationTarget >> int [
	^ SLVMType intType
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
	^ objectModel
]

{ #category : #accessing }
SLVMCompilationTarget >> objectModel: anObject [
	objectModel := anObject.
	objectModel target: self
]

{ #category : #accessing }
SLVMCompilationTarget >> pointerAlignment [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMCompilationTarget >> pointerSize [
	self subclassResponsibility
]

{ #category : #types }
SLVMCompilationTarget >> pointerTo: baseType [
	^ self pointerTo: baseType storage: SLVMType genericStorage
]

{ #category : #types }
SLVMCompilationTarget >> pointerTo: baseType storage: storageClass [
	^ SLVMPointerType size: self pointerSize baseType: baseType storage: storageClass
]

{ #category : #accessing }
SLVMCompilationTarget >> referenceAlignment [
	^ self pointerAlignment
]

{ #category : #accessing }
SLVMCompilationTarget >> referenceSize [
	^ self pointerSize
]

{ #category : #types }
SLVMCompilationTarget >> short [
	^ SLVMType shortType
]

{ #category : #types }
SLVMCompilationTarget >> uchar [
	^ SLVMType ucharType
]

{ #category : #types }
SLVMCompilationTarget >> uint [
	^ SLVMType uintType
]

{ #category : #types }
SLVMCompilationTarget >> ulong [
	^ SLVMType ulongType
]

{ #category : #types }
SLVMCompilationTarget >> ushort [
	^ SLVMType ushortType
]

{ #category : #types }
SLVMCompilationTarget >> void [
	^ SLVMType voidType
]

{ #category : #types }
SLVMCompilationTarget >> voidPointerType [
	^ voidPointerType ifNil: [ voidPointerType := self pointerTo: self void ]
]

{ #category : #initialization }
SLVMCompilationTarget >> withDebugInformation [
	self emittingDebugInformation: true
]

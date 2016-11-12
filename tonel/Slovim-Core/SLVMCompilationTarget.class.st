Class {
	#name : #SLVMCompilationTarget,
	#superclass : #SLVMObject,
	#instVars : [
		'dynamicObjectType',
		'voidPointerType'
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
	^ SLVMType doubleType
]

{ #category : #accessing }
SLVMCompilationTarget >> dynamicObjectType [
	^ dynamicObjectType ifNil: [ dynamicObjectType := SLVMDynamicObjectType new size: self pointerSize ]
]

{ #category : #types }
SLVMCompilationTarget >> float [
	^ SLVMType floatType
]

{ #category : #convenience }
SLVMCompilationTarget >> generateLowLevelModule: aModule [
	^ self lowLevelCodeGeneratorClass translateModule: aModule
]

{ #category : #types }
SLVMCompilationTarget >> int [
	^ SLVMType intType
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
	^ 8
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

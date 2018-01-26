"
I contain the types for a compilation target. I can be used to share types between different compilation targets.
"
Class {
	#name : #SLVMCompilationTargetTypes,
	#superclass : #SLVMObject,
	#instVars : [
		'dynamicObjectType',
		'voidPointerType',
		'objectModel'
	],
	#classVars : [
		'CurrentImageCompilationTypes'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #'as yet unclassified' }
SLVMCompilationTargetTypes class >> createForCurrentImage [
	^ Smalltalk wordSize = 4 ifTrue: [ SLVM32BitsPointerCompilationTargetTypes new ] ifFalse: [ SLVM64BitsPointerCompilationTargetTypes new ]
]

{ #category : #'as yet unclassified' }
SLVMCompilationTargetTypes class >> forCurrentImage [
	^ CurrentImageCompilationTypes ifNil: [ CurrentImageCompilationTypes := self createForCurrentImage ]
]

{ #category : #types }
SLVMCompilationTargetTypes >> bool [
	^ SLVMType boolType
]

{ #category : #types }
SLVMCompilationTargetTypes >> char [
	^ SLVMType charType
]

{ #category : #types }
SLVMCompilationTargetTypes >> double [
	^ self subclassResponsibility
]

{ #category : #types }
SLVMCompilationTargetTypes >> doubleAlign4 [
	^ SLVMType doubleAlign4Type
]

{ #category : #types }
SLVMCompilationTargetTypes >> doubleAlign8 [
	^ SLVMType doubleAlign8Type
]

{ #category : #types }
SLVMCompilationTargetTypes >> dynamicObjectType [
	^ dynamicObjectType ifNil: [ dynamicObjectType := SLVMDynamicObjectType new size: self pointerSize ]
]

{ #category : #types }
SLVMCompilationTargetTypes >> float [
	^ SLVMType floatType
]

{ #category : #types }
SLVMCompilationTargetTypes >> float32 [
	^ self float
]

{ #category : #types }
SLVMCompilationTargetTypes >> float64 [
	^ self double
]

{ #category : #types }
SLVMCompilationTargetTypes >> int [
	^ SLVMType intType
]

{ #category : #types }
SLVMCompilationTargetTypes >> int16 [
	^ self short
]

{ #category : #types }
SLVMCompilationTargetTypes >> int32 [
	^ self int
]

{ #category : #types }
SLVMCompilationTargetTypes >> int64 [
	^ self long
]

{ #category : #types }
SLVMCompilationTargetTypes >> int8 [
	^ self char
]

{ #category : #types }
SLVMCompilationTargetTypes >> long [
	^ SLVMType longType
]

{ #category : #accessing }
SLVMCompilationTargetTypes >> objectModel [
	^ objectModel ifNil: [objectModel := SLVMNativeRuntimeObjectModel new target: self.]
]

{ #category : #accessing }
SLVMCompilationTargetTypes >> objectModel: anObjectModel [
	objectModel := anObjectModel.
	anObjectModel target: self
]

{ #category : #accessing }
SLVMCompilationTargetTypes >> pointerAlignment [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMCompilationTargetTypes >> pointerSize [
	self subclassResponsibility
]

{ #category : #types }
SLVMCompilationTargetTypes >> pointerTo: baseType [
	^ self pointerTo: baseType storage: SLVMType genericStorage
]

{ #category : #types }
SLVMCompilationTargetTypes >> pointerTo: baseType storage: storageClass [
	^ SLVMPointerType size: self pointerSize baseType: baseType storage: storageClass
]

{ #category : #accessing }
SLVMCompilationTargetTypes >> referenceAlignment [
	^ self pointerAlignment
]

{ #category : #accessing }
SLVMCompilationTargetTypes >> referenceSize [
	^ self pointerSize
]

{ #category : #types }
SLVMCompilationTargetTypes >> short [
	^ SLVMType shortType
]

{ #category : #types }
SLVMCompilationTargetTypes >> uchar [
	^ SLVMType ucharType
]

{ #category : #types }
SLVMCompilationTargetTypes >> uint [
	^ SLVMType uintType
]

{ #category : #types }
SLVMCompilationTargetTypes >> uint16 [
	^ self ushort
]

{ #category : #types }
SLVMCompilationTargetTypes >> uint32 [
	^ self uint
]

{ #category : #types }
SLVMCompilationTargetTypes >> uint64 [
	^ self ulong
]

{ #category : #types }
SLVMCompilationTargetTypes >> uint8 [
	^ self uchar
]

{ #category : #types }
SLVMCompilationTargetTypes >> ulong [
	^ SLVMType ulongType
]

{ #category : #types }
SLVMCompilationTargetTypes >> ushort [
	^ SLVMType ushortType
]

{ #category : #types }
SLVMCompilationTargetTypes >> void [
	^ SLVMType voidType
]

{ #category : #types }
SLVMCompilationTargetTypes >> voidPointerType [
	^ voidPointerType ifNil: [ voidPointerType := self pointerTo: self void ]
]
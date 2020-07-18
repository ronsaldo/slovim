"
I contain the types for a compilation target. I can be used to share types between different compilation targets.
"
Class {
	#name : #SLVMCompilationTargetTypes,
	#superclass : #SLVMObject,
	#instVars : [
		'dynamicObjectType',
		'voidPointerType',
		'objectModel',
		'voidPointerPointerType',
		'textureTypeWithFormat'
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
SLVMCompilationTargetTypes >> anonStructure: slots [
	^ SLVMStructureType
		name: nil types: slots
		kind: SLVMStructureType genericKind names:
		(slots collectWithIndex: [:s :i | ('s', i asString) asSymbol])
]

{ #category : #types }
SLVMCompilationTargetTypes >> arrayOf: elementType size: size [
	^ SLVMArrayType baseType: elementType elements: size
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
SLVMCompilationTargetTypes >> depthTexture2D [
	^ SLVMType depthTexture2DType
]

{ #category : #types }
SLVMCompilationTargetTypes >> depthTexture2DArray [
	^ SLVMType depthTexture2DArrayType
]

{ #category : #types }
SLVMCompilationTargetTypes >> depthTextureCube [
	^ SLVMType depthTextureCubeType
]

{ #category : #types }
SLVMCompilationTargetTypes >> depthTextureCubeArray [
	^ SLVMType depthTextureCubeArrayType
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

{ #category : #initialization }
SLVMCompilationTargetTypes >> initialize [
	super initialize.
	textureTypeWithFormat := Dictionary new.
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

{ #category : #types }
SLVMCompilationTargetTypes >> matrix: aBaseType rows: numRows columns: numColumns [
	^ SLVMMatrixType baseType: aBaseType rows: numRows columns: numColumns
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
SLVMCompilationTargetTypes >> sampler [
	^ SLVMType samplerType
]

{ #category : #types }
SLVMCompilationTargetTypes >> short [
	^ SLVMType shortType
]

{ #category : #types }
SLVMCompilationTargetTypes >> texture1D [
	^ SLVMType texture1DType
]

{ #category : #types }
SLVMCompilationTargetTypes >> texture1DArray [
	^ SLVMType texture1DArrayType
]

{ #category : #types }
SLVMCompilationTargetTypes >> texture2D [
	^ SLVMType texture2DType
]

{ #category : #types }
SLVMCompilationTargetTypes >> texture2DArray [
	^ SLVMType texture2DArrayType
]

{ #category : #types }
SLVMCompilationTargetTypes >> texture3D [
	^ SLVMType texture3DType
]

{ #category : #types }
SLVMCompilationTargetTypes >> texture3DArray [
	^ SLVMType texture3DArrayType
]

{ #category : #types }
SLVMCompilationTargetTypes >> textureCube [
	^ SLVMType textureCubeType
]

{ #category : #types }
SLVMCompilationTargetTypes >> textureCubeArray [
	^ SLVMType textureCubeArrayType
]

{ #category : #types }
SLVMCompilationTargetTypes >> textureType: baseTextureType versionWithFormat: requiredFormat [
	| targetType |
	targetType := baseTextureType copy format: requiredFormat.
	^ textureTypeWithFormat at: targetType ifAbsentPut: [ targetType ]
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
SLVMCompilationTargetTypes >> valist [
	^ self voidPointerType
]

{ #category : #types }
SLVMCompilationTargetTypes >> vector: baseType elements: elements [
	^ SLVMVectorType baseType: baseType elements: elements
]

{ #category : #types }
SLVMCompilationTargetTypes >> void [
	^ SLVMType voidType
]

{ #category : #types }
SLVMCompilationTargetTypes >> voidPointerPointerType [
	^ voidPointerPointerType ifNil: [ voidPointerPointerType := self pointerTo: self voidPointerType ]
]

{ #category : #types }
SLVMCompilationTargetTypes >> voidPointerType [
	^ voidPointerType ifNil: [ voidPointerType := self pointerTo: self void ]
]

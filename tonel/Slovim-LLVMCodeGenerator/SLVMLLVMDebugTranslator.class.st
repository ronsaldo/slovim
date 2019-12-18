Class {
	#name : #SLVMLLVMDebugTranslator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'moduleTranslator'
	],
	#pools : [
		'SAsmDWConstants'
	],
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #accessing }
SLVMLLVMDebugTranslator >> llvmModule [
	^ moduleTranslator llvmModule
]

{ #category : #accessing }
SLVMLLVMDebugTranslator >> moduleTranslator [
	^ moduleTranslator
]

{ #category : #accessing }
SLVMLLVMDebugTranslator >> moduleTranslator: anObject [
	moduleTranslator := anObject
]

{ #category : #'code generation' }
SLVMLLVMDebugTranslator >> translate: aDebugElement [
	^ aDebugElement accept: self
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> translateStructureType: type tag: tag [
	| compositeType offset memberType derivedType |
	compositeType := (LLVMDICompositeType for: self llvmModule)
		distinct;
		name: type name;
		tag: tag;
		file: moduleTranslator unknownDebugFile;
		size: type size*8;
		align: type alignment*8;
		elements: (LLVMMDTuple for: self llvmModule);
		yourself.
		
	type names doWithIndex: [ :name :index |
		offset := type offsets at: index.
		memberType := type types at: index.
		
		derivedType := (LLVMDIDerivedType for: self llvmModule)
			tag: DW_TAG_member;
			name: name;
			size: memberType size * 8;
			baseType: (moduleTranslator translateDebugType: memberType);
			offset: offset*8;
			yourself.
		compositeType elements addElement: derivedType.
	].

	moduleTranslator register: type debugElement: compositeType.
	^ compositeType

]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitArrayType: type [
	| compositeType |
	compositeType := (LLVMDICompositeType for: self llvmModule)
		name: type name;
		tag: DW_TAG_array_type;
		file: moduleTranslator unknownDebugFile;
		size: type size*8;
		align: type alignment*8;
		elements: ((LLVMMDTuple for: self llvmModule)
			elements: {(LLVMDISubrange for: self llvmModule)
					count: type validElements;
					yourself
			};
		yourself).
	compositeType baseType: (moduleTranslator translateDebugType: type baseType).
	moduleTranslator register: type debugElement: compositeType.
	^ compositeType
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitBoolType: type [
	| basicType |
	basicType := (LLVMDIBasicType for: self llvmModule)
		name: type name;
		size: type size*8;
		align: type alignment*8;
		encoding: DW_ATE_boolean;
		yourself.
	moduleTranslator register: type debugElement: basicType.
	
	^ basicType
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitDynamicObjectType: type [
	| derivedType |
	derivedType := (LLVMDIDerivedType for: self llvmModule)
		tag: DW_TAG_pointer_type;
		size: type size*8;
		align: type alignment*8;
		yourself.
	moduleTranslator register: type debugElement: derivedType.
	derivedType baseType: (moduleTranslator translateDebugType: SLVMType ucharType).
	^ derivedType
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitFloatType: type [
	| basicType |
	basicType := (LLVMDIBasicType for: self llvmModule)
		name: type name;
		size: type size*8;
		align: type alignment*8;
		encoding: DW_ATE_float;
		yourself.
	moduleTranslator register: type debugElement: basicType.
	
	^ basicType
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitFunctionType: aFunctionType [
	| subroutineType returnType argumentTypes |
	subroutineType := LLVMDISubroutineType for: self llvmModule.
	moduleTranslator register: aFunctionType debugElement: subroutineType.
	
	returnType := moduleTranslator translateDebugType: aFunctionType returnType.
	argumentTypes := aFunctionType arguments collect: [:arg | moduleTranslator translateDebugType: arg].
	subroutineType types: (LLVMMDTuple for: self llvmModule rawElements: { returnType } , argumentTypes).
	
	^ subroutineType
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitIntegerType: type [
	| basicType |
	basicType := (LLVMDIBasicType for: self llvmModule)
		name: type name;
		size: type size*8;
		align: type alignment*8;
		encoding: (type isUnsigned ifTrue: [ DW_ATE_unsigned ] ifFalse: [DW_ATE_signed ]);
		yourself.
	moduleTranslator register: type debugElement: basicType.
	
	^ basicType
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitMatrixType: type [
	| compositeType |
	compositeType := (LLVMDICompositeType for: self llvmModule)
		distinct;
		name: type name;
		tag: DW_TAG_structure_type;
		file: moduleTranslator unknownDebugFile;
		size: type size*8;
		align: type alignment*8;
		elements: (LLVMMDTuple for: self llvmModule);
		yourself.
	moduleTranslator register: type debugElement: compositeType.
	^ compositeType
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitPackedStructureType: type [
	^ self translateStructureType: type tag: DW_TAG_structure_type
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitPointerType: type [
	| derivedType |
	derivedType := (LLVMDIDerivedType for: self llvmModule)
		tag: DW_TAG_pointer_type;
		size: type size*8;
		align: type alignment*8;
		yourself.
	moduleTranslator register: type debugElement: derivedType.
	type baseType isVoidType ifTrue: [
		derivedType baseType: (moduleTranslator translateDebugType: SLVMType ucharType).
	] ifFalse: [ 
		derivedType baseType: (moduleTranslator translateDebugType: type baseType).
	].
	
	^ derivedType
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitStructureType: type [
	^ self translateStructureType: type tag: DW_TAG_structure_type
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitUnionType: type [
	^ self translateStructureType: type tag: DW_TAG_union_type
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitVectorType: type [
	| compositeType |
	compositeType := (LLVMDICompositeType for: self llvmModule)
		distinct;
		name: type name;
		tag: DW_TAG_structure_type;
		file: moduleTranslator unknownDebugFile;
		size: type size*8;
		align: type alignment*8;
		elements: (LLVMMDTuple for: self llvmModule);
		yourself.
	moduleTranslator register: type debugElement: compositeType.
	^ compositeType
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitVoidType: type [
	moduleTranslator register: type debugElement: nil.
	^ nil
]

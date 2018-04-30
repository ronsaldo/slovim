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
SLVMLLVMDebugTranslator >> visitPointerType: type [
	| derivedType |
	derivedType := (LLVMDIDerivedType for: self llvmModule)
		tag: DW_TAG_pointer_type;
		size: type size*8;
		align: type alignment*8;
		yourself.
	moduleTranslator register: type debugElement: derivedType.
	type baseType isVoidType ifTrue: [
		self halt
	] ifFalse: [ 
		derivedType baseType: (moduleTranslator translateDebugType: type baseType).
	].
	
	^ derivedType
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitStructureType: type [
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

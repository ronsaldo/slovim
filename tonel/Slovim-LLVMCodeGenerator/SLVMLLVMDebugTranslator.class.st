Class {
	#name : #SLVMLLVMDebugTranslator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'moduleTranslator'
	],
	#classVars : [
		'EncodingFromDebugTypeKind',
		'TagFromDebugTypeKind'
	],
	#pools : [
		'SAsmDWConstants'
	],
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #'class initialization' }
SLVMLLVMDebugTranslator class >> initialize [
	TagFromDebugTypeKind := Dictionary newFromPairs: { 
		"Derived types"
		#pointer . DW_TAG_pointer_type.
		#reference . DW_TAG_reference_type.
		#const . DW_TAG_const_type.
		#volatile . DW_TAG_volatile_type.
		#restrict . DW_TAG_restrict_type.
		#member . DW_TAG_member.
		#inheritance . DW_TAG_inheritance.

		"Composite type"
		#class . DW_TAG_class_type.
		#structure . DW_TAG_structure_type.
		#union . DW_TAG_union_type.
		#array . DW_TAG_array_type.
		#enumeration . DW_TAG_enumeration_type.
	}.
	
	EncodingFromDebugTypeKind := Dictionary newFromPairs: { 
		"Derived types"
		#boolean . DW_ATE_boolean.
		#float . DW_ATE_float.
		#signed . DW_ATE_signed.
		#unsigned . DW_ATE_unsigned.
		#character . DW_ATE_unsigned_char.
	}.
]

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

{ #category : #'as yet unclassified' }
SLVMLLVMDebugTranslator >> translateDebugType: debugType commonParametersInto: llvmDebugType [
	debugType parentScope ifNotNil: [ :parentScope |
		llvmDebugType scope: (moduleTranslator convertDebugScope: parentScope fallbackTo: nil)
	]


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
SLVMLLVMDebugTranslator >> visitDebugBasicType: debugType [
	| basicType |
	debugType kind = #void ifTrue: [
		moduleTranslator register: debugType debugElement: nil.
		^ nil
	].
	basicType := (LLVMDIBasicType for: self llvmModule)
		name: debugType name;
		size: debugType bitSize;
		align: debugType bitAlignment;
		encoding: (EncodingFromDebugTypeKind at: debugType kind);
		yourself.
	moduleTranslator register: debugType debugElement: basicType.
	self translateDebugType: debugType commonParametersInto: basicType.

	^ basicType

]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitDebugCompositeType: debugType [
	| compositeType |
	compositeType := (LLVMDICompositeType for: self llvmModule)
		distinct;
		name: debugType name;
		tag: (TagFromDebugTypeKind at: debugType kind);
		file: moduleTranslator unknownDebugFile;
		size: debugType bitSize;
		align: debugType bitAlignment;
		elements: (LLVMMDTuple for: self llvmModule);
		yourself.
	moduleTranslator register: debugType debugElement: compositeType.
	self translateDebugType: debugType commonParametersInto: compositeType.
	
	debugType baseType ifNotNil: [ 
		compositeType baseType: (moduleTranslator translateDebugType: debugType baseType)
	].
	
	debugType kind = #array ifTrue: [ 
		compositeType elements elements: {(LLVMDISubrange for: self llvmModule)
				count: (debugType arrayRange ifNil: [0]);
				yourself
		}
	] ifFalse: [
		debugType members do: [ :member |
			compositeType elements addElement: (moduleTranslator translateDebugType: member)
		].
	].

	^ compositeType
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitDebugDerivedType: debugType [
	| derivedType |
	derivedType := (LLVMDIDerivedType for: self llvmModule)
		name: debugType name;
		tag: (TagFromDebugTypeKind at: debugType kind);
		size: debugType bitSize;
		align: debugType bitAlignment;
		offset: debugType bitOffset;
		yourself.
	moduleTranslator register: debugType debugElement: derivedType.
	derivedType baseType: (moduleTranslator translateDebugType: debugType baseType).
	self translateDebugType: debugType commonParametersInto: derivedType.
	
	debugType isBitField ifTrue: [ 
		derivedType
			flags: (LLVMNamedFlags with: #(DIFlagBitField));
			extraData: (moduleTranslator context int64Ty constant: 64) asLLVMMetadata
	].
	
	^ derivedType
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitDebugLexicalScope: debugLexicalScope [
	| lexicalScope |
	lexicalScope := (LLVMDILexicalBlock for: self llvmModule)
		distinct;
		yourself.
	moduleTranslator register: debugLexicalScope debugElement: lexicalScope.
	
	debugLexicalScope parentScope ifNotNil: [ :parentScope |
		lexicalScope scope: (moduleTranslator convertDebugScope: parentScope fallbackTo: moduleTranslator debugCompileUnit)
	].

	lexicalScope
		file: (debugLexicalScope file ifNotNil: [:f | moduleTranslator convertDebugFile: f]);
		line: debugLexicalScope startLine;
		column: debugLexicalScope startColumn.

	^ lexicalScope
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitDebugNamespace: debugNamespace [
	| namespace |
	namespace := (LLVMDINamespace for: self llvmModule)
		distinct;
		name: debugNamespace name;
		yourself.
	moduleTranslator register: debugNamespace debugElement: namespace.
	debugNamespace parentScope ifNotNil: [ :parentScope |
		debugNamespace scope: (moduleTranslator convertDebugScope: parentScope fallbackTo: nil)
	].

	^ namespace
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitDebugSubprogram: debugSubprogram [
	| subprogram |
	subprogram := (LLVMDISubprogram for: self llvmModule)
		distinct;
		scope: moduleTranslator debugCompileUnit;
		unit: moduleTranslator debugCompileUnit;
		name: debugSubprogram name;
		isLocal: debugSubprogram isLocal;
		isDefinition: debugSubprogram isDefinition;
		retainedNodes: (LLVMMDDynamicTuple for: self llvmModule)
		yourself.
	moduleTranslator register: debugSubprogram debugElement: subprogram.
	
	subprogram type: (moduleTranslator translateDebugType: debugSubprogram type).
	
	debugSubprogram parentScope ifNotNil: [ :parentScope |
		subprogram scope: (moduleTranslator convertDebugScope: parentScope fallbackTo: moduleTranslator debugCompileUnit)
	].

	^ subprogram
]

{ #category : #visiting }
SLVMLLVMDebugTranslator >> visitDebugSubroutineType: debugType [
	| subroutineType returnType argumentTypes |
	subroutineType := LLVMDISubroutineType for: self llvmModule.
	moduleTranslator register: debugType debugElement: subroutineType.
	
	returnType := moduleTranslator translateDebugType: debugType returnType.
	argumentTypes := debugType argumentTypes collect: [:arg | moduleTranslator translateDebugType: arg].
	subroutineType types: (LLVMMDTuple for: self llvmModule rawElements: { returnType } , argumentTypes).
	
	^ subroutineType
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

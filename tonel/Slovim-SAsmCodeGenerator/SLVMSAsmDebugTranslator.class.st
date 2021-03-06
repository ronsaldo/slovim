Class {
	#name : #SLVMSAsmDebugTranslator,
	#superclass : #Object,
	#instVars : [
		'codeGenerator'
	],
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #accessing }
SLVMSAsmDebugTranslator >> codeGenerator [
	^ codeGenerator
]

{ #category : #accessing }
SLVMSAsmDebugTranslator >> codeGenerator: anObject [
	codeGenerator := anObject
]

{ #category : #translate }
SLVMSAsmDebugTranslator >> translate: anElement [
	^ anElement accept: self
]

{ #category : #visiting }
SLVMSAsmDebugTranslator >> visitArrayType: type [
	codeGenerator buildDebugInformation: [ :builder |
		builder arrayType: [ :debugType |
			codeGenerator register: type debugElement: debugType.
			debugType
				byteSize: type size;
				type: (codeGenerator translateDebugType: type baseType).
				
			builder subrangeType: [ :subrangeType |
				subrangeType upperBound: (type validElements - 1 max: 0)
			].
		]
	].

]

{ #category : #visiting }
SLVMSAsmDebugTranslator >> visitBoolType: type [
	codeGenerator buildDebugInformation: [ :builder |
		builder baseType: [ :debugType |
			codeGenerator register: type debugElement: debugType.
			debugType
				name: type name;
				byteSize: type size;
				encodingBoolean
		]
	].

]

{ #category : #visiting }
SLVMSAsmDebugTranslator >> visitDynamicObjectType: type [
	codeGenerator buildDebugInformation: [ :builder |
		codeGenerator objectModel objectHeaderType ifNotNil: [ :objectHeaderType |
			builder typedef: [ :debugType |
				codeGenerator register: type debugElement: debugType.

				debugType
					name: #_Oop;
					type: (codeGenerator translateDebugType: (SLVMPointerType size: type size baseType: objectHeaderType storage: type storage))
			]

		] ifNil: [ 
			builder baseType: [ :debugType |
				codeGenerator register: type debugElement: debugType.

				debugType
					name: #_Oop;
					byteSize: type size
			]
		]
	].

]

{ #category : #visiting }
SLVMSAsmDebugTranslator >> visitFloatType: type [
	codeGenerator buildDebugInformation: [ :builder |
		builder baseType: [ :debugType |
			codeGenerator register: type debugElement: debugType.
			debugType
				name: type name;
				byteSize: type size;
				encodingFloat
		]
	].

]

{ #category : #visiting }
SLVMSAsmDebugTranslator >> visitFunctionType: type [
	codeGenerator buildDebugInformation: [ :builder |
		builder subroutineType: [ :debugType |
			codeGenerator register: type debugElement: debugType.
			debugType
				type: (codeGenerator translateDebugType: type returnType).
				
			type arguments do: [ :arg |
				builder formalParameter: [ :parameter |
					parameter type: (codeGenerator translateDebugType: arg).
				]
			]
		]
	].

]

{ #category : #visiting }
SLVMSAsmDebugTranslator >> visitIntegerType: type [
	codeGenerator buildDebugInformation: [ :builder |
		builder baseType: [ :debugType |
			codeGenerator register: type debugElement: debugType.
			debugType
				name: type name;
				byteSize: type size.
			type isUnsigned ifTrue: [ debugType encodingUnsigned ] ifFalse: [ debugType encodingSigned ]
		]
	].

]

{ #category : #visiting }
SLVMSAsmDebugTranslator >> visitPointerType: type [
	codeGenerator buildDebugInformation: [ :builder |
		builder pointerType: [ :debugType |
			codeGenerator register: type debugElement: debugType.
			debugType
				byteSize: type size;
				type: (codeGenerator translateDebugType: type baseType)
		]
	].

]

{ #category : #visiting }
SLVMSAsmDebugTranslator >> visitStructureType: type [
	| offset memberType |
	codeGenerator buildDebugInformation: [ :builder |
		builder structureType: [ :debugType |
			codeGenerator register: type debugElement: debugType.
			type name ifNotNil: [ debugType name: type name ].
			debugType
				byteSize: type size.
				
			type names doWithIndex: [ :name :index |
				offset := type offsets at: index.
				memberType := type types at: index.
				builder member: [ :member |
					member
						name: name;
						type: (codeGenerator translateDebugType: memberType);
						dataMemberLocation: offset.
				]
			]
		]
	].

]

{ #category : #visiting }
SLVMSAsmDebugTranslator >> visitVoidType: type [
	codeGenerator buildDebugInformation: [ :builder |
		builder baseType: [ :debugType |
			codeGenerator register: type debugElement: debugType.
			debugType
				name: type name;
				byteSize: 0
		]
	].

]

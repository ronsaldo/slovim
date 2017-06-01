Class {
	#name : #SLVMSAsmConstantDataGenerator,
	#superclass : #SLVMSAsmConstantCodeGenerator,
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #visiting }
SLVMSAsmConstantDataGenerator >> emitImmediateLiteralIntegerObject: value [
	^ SAsmConstantExpressionConstantInteger new
		size: target pointerSize;
		value: value;
		yourself.
]

{ #category : #visiting }
SLVMSAsmConstantDataGenerator >> emitImmediateLiteralObject: constant [
	| value |
	value := constant value.
	value ifNil: [ ^ self emitImmediateLiteralIntegerObject: 0 ].
	value isInteger ifTrue: [
		target pointerSize = 4 ifTrue: [ 
			^ self emitImmediateLiteralIntegerObject: (value << 1) | 1
		] ifFalse: [ 
			^ self emitImmediateLiteralIntegerObject: (value << 3) | 1
		]
	].
	
	self halt
	
]

{ #category : #visiting }
SLVMSAsmConstantDataGenerator >> visitConstantArrayValue: array [
	| slots type |
	slots := array slots collect: [ :slot | (self translate: slot) asSAsmConstantExpression ].
	type := array type.
	^ SAsmConstantExpressionConstantArray new
		size: type size;
		elementSize: type baseType size;
		elementAlignment: type baseType alignment;
		slots: slots
]

{ #category : #visiting }
SLVMSAsmConstantDataGenerator >> visitConstantStructureValue: structure [
	| slots type |
	slots := structure slots collect: [ :slot | (self translate: slot) asSAsmConstantExpression].
	type := structure type.
	^ SAsmConstantExpressionConstantStructure new
		size: type size;
		alignment: type alignment;
		slots: slots;
		slotAlignments: (structure slots collect: [ :slot | slot type alignment])
]

{ #category : #visiting }
SLVMSAsmConstantDataGenerator >> visitConstantValue: constant [
	| type |
	type := constant type.
	type isScalarType ifTrue: [ 
		type isIntegerType ifTrue: [
			^ SAsmConstantExpressionConstantInteger new
				size: type size;
				value: constant value;
				yourself.
		].

		type isFloatType ifTrue: [
			^ SAsmConstantExpressionConstantFloat new
				size: type size;
				value: constant value;
				yourself.
		].
	
		type isDynamicObjectType ifTrue: [ 
			^ self emitImmediateLiteralObject: constant
		]
	].

	^ SAsmConstantExpressionConstantBlob new value: constant asBlob; yourself
]

{ #category : #visiting }
SLVMSAsmConstantDataGenerator >> visitFunction: aFunction [
	^ (moduleTranslator translateModuleElement: aFunction) asSAsmInstructionOperand
]

{ #category : #visiting }
SLVMSAsmConstantDataGenerator >> visitGlobalVariable: aGlobalVariable [
	^ (moduleTranslator translateModuleElement: aGlobalVariable) asSAsmInstructionOperand
]

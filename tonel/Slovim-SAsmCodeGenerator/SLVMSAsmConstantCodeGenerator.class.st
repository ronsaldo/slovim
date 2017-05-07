Class {
	#name : #SLVMSAsmConstantCodeGenerator,
	#superclass : #Object,
	#instVars : [
		'target',
		'sasmTarget',
		'moduleElement',
		'moduleTranslator',
		'dataGenerator'
	],
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #visiting }
SLVMSAsmConstantCodeGenerator >> addToConstantZone: constantData [
	| builder symbol |
	builder := moduleElement constantZoneBuilder.
	symbol := builder newPrivateSymbol: #constant.
	builder label: symbol;
		add: constantData.
		
	^ symbol
]

{ #category : #accessing }
SLVMSAsmConstantCodeGenerator >> dataGenerator [
	^ dataGenerator ifNil: [ dataGenerator := self as: SLVMSAsmConstantDataGenerator ]
]

{ #category : #testing }
SLVMSAsmConstantCodeGenerator >> isImmediateConstantType: constantType [
	constantType isScalarType ifTrue: [ 
		self flag: 'Refine this search.'.
		^ true
	].
	^ false
]

{ #category : #accessing }
SLVMSAsmConstantCodeGenerator >> moduleElement [
	^ moduleElement
]

{ #category : #accessing }
SLVMSAsmConstantCodeGenerator >> moduleElement: anObject [
	moduleElement := anObject
]

{ #category : #accessing }
SLVMSAsmConstantCodeGenerator >> moduleTranslator [
	^ moduleTranslator
]

{ #category : #accessing }
SLVMSAsmConstantCodeGenerator >> moduleTranslator: anObject [
	moduleTranslator := anObject
]

{ #category : #accessing }
SLVMSAsmConstantCodeGenerator >> sasmTarget [
	^ sasmTarget
]

{ #category : #accessing }
SLVMSAsmConstantCodeGenerator >> sasmTarget: anObject [
	sasmTarget := anObject
]

{ #category : #accessing }
SLVMSAsmConstantCodeGenerator >> target [
	^ target
]

{ #category : #accessing }
SLVMSAsmConstantCodeGenerator >> target: anObject [
	target := anObject
]

{ #category : #visiting }
SLVMSAsmConstantCodeGenerator >> translate: aValue [
	^ aValue accept: self
]

{ #category : #visiting }
SLVMSAsmConstantCodeGenerator >> translateImmediateConstantValue: value [
	| data integerImmediate |
	integerImmediate := 0.
	value type isIntegerType ifTrue: [
		integerImmediate := value value.
	] ifFalse: [ 
		data := value asBlob.
		integerImmediate := 0.
		data reverseDo: [ :element |
			integerImmediate := (integerImmediate << 8) | element.
		].
	].

	^ self translateIntegerImmediate: integerImmediate size: value type size
]

{ #category : #visiting }
SLVMSAsmConstantCodeGenerator >> translateIntegerImmediate: integerImmediate size: size [
	target pointerSize < size ifTrue: [ 
		self assert: (size = 8 and: [target pointerSize = 4]).
		^ { "Lower" (integerImmediate & 16rFFFFFFFF) asSAsmInstructionOperand .
			 "High" ((integerImmediate >> 32) & 16rFFFFFFFF) asSAsmInstructionOperand}
	].
	^ { integerImmediate asSAsmInstructionOperand }
]

{ #category : #visiting }
SLVMSAsmConstantCodeGenerator >> visitConstantPointer: aConstant [
	| constantData |
	constantData := self dataGenerator translate: aConstant constant.
	^ self addToConstantZone: (SAsmConstantExpressionValue new size: constantData size; value: constantData)
]

{ #category : #visiting }
SLVMSAsmConstantCodeGenerator >> visitConstantValue: value [
	(self isImmediateConstantType: value type) ifTrue: [
		^ self translateImmediateConstantValue: value
	] ifFalse: [ 
		self halt
	].
	
]

{ #category : #visiting }
SLVMSAsmConstantCodeGenerator >> visitFunction: aFunction [
	^ (aFunction accept: moduleTranslator) asSAsmInstructionOperand
]

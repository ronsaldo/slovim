Class {
	#name : #SLVMObjectModel,
	#superclass : #SLVMObject,
	#instVars : [
		'target'
	],
	#classVars : [
		'SmallFloatExponentMax',
		'SmallFloatExponentMin',
		'SmallFloatExponentOffset'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #initialization }
SLVMObjectModel class >> initialize [
	SmallFloatExponentOffset := "1023 - 127" 896.
	SmallFloatExponentMin := "1023 - 127" SmallFloatExponentOffset.
	SmallFloatExponentMax := "1023 + 128" 1151.

]

{ #category : #'as yet unclassified' }
SLVMObjectModel >> closureHeaderType [
	^ nil
]

{ #category : #'as yet unclassified' }
SLVMObjectModel >> closureInstantiateFunction [
	^ nil
]

{ #category : #'as yet unclassified' }
SLVMObjectModel >> compiledMethodLiteralsOffset [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SLVMObjectModel >> compiledMethodMetadataLiteralOffsetWithIndex: index [
	^ target pointerSize * (index - 1) + self compiledMethodLiteralsOffset
]

{ #category : #'as yet unclassified' }
SLVMObjectModel >> contextMetaDataHeaderSize [
	self subclassResponsibility
]

{ #category : #'trampoline names' }
SLVMObjectModel >> convertConstantValue: value inModule: module [
	self halt
]

{ #category : #'literal conversion' }
SLVMObjectModel >> convertInlineLiteral: literal [
	^ SLVMConstantValue type: target dynamicObjectType value: literal
]

{ #category : #'literal conversion' }
SLVMObjectModel >> convertNonInlineLiteral: literal [
	^ literal
]

{ #category : #visiting }
SLVMObjectModel >> createFunctionContextMetaData: function [
	self subclassResponsibility
]

{ #category : #'immediate literals' }
SLVMObjectModel >> encodeCharacter: character [
	| codePoint |
	codePoint := character asInteger.
	target pointerSize = 4 ifTrue: [
		^ (codePoint << 2) | 2
	] ifFalse: [
		^ (codePoint << 3) | 2
	]
	
]

{ #category : #'immediate literals' }
SLVMObjectModel >> encodeSmallFloat: float [
	| data bits |
	self assert: target pointerSize = 8.
	data := ((float basicAt: 1) << 32) | (float basicAt: 2).
	
	bits := self rotate64Left1: data.
	bits := bits - (SmallFloatExponentOffset << 53).
	bits := ((bits << 3) | 4) & 16rFFFFFFFFFFFFFFFF.
	^ bits
]

{ #category : #'immediate literals' }
SLVMObjectModel >> encodeSmallInteger: integer [
	target pointerSize = 4 ifTrue: [
		^ (integer << 1) | 1
	] ifFalse: [
		^ (integer << 3) | 1
	]
	
]

{ #category : #'as yet unclassified' }
SLVMObjectModel >> fillClosureStructure: closureStructureType functionPointerType: closureFunctionPointer capturedEnvironmentStructure: capturedEnvironmentStructure [
	self closureHeaderType ifNotNil: [ :objectHeader |
		closureStructureType
			types: { objectHeader . closureFunctionPointer . capturedEnvironmentStructure };
			names: #(objectHeader function environment).
		closureFunctionPointer baseType argumentAt: 1 addAttribute: #dynobject.
	] ifNil: [
		closureStructureType
			types: { closureFunctionPointer . capturedEnvironmentStructure };
			names: #(function environment)
	]
	
]

{ #category : #testing }
SLVMObjectModel >> isInlineLiteral: literal [
	| literalClass |
	literalClass := literal class.
	(literalClass includesBehavior: Boolean) ifTrue: [ ^ true].
	(literalClass includesBehavior: Character) ifTrue: [ ^ true].
	(literalClass includesBehavior: Float) ifTrue: [ ^ self isSmallFloat: literal ].
	(literalClass includesBehavior: Integer) ifTrue: [ ^ self isSmallInteger: literal ].
	(literalClass includesBehavior: UndefinedObject) ifTrue: [ ^ true].
	^ false
]

{ #category : #'immediate literals' }
SLVMObjectModel >> isSmallFloat: float [
	| data exponent |
	target pointerSize < 8 ifTrue: [ ^ false ].
	
	data := ((float basicAt: 1) << 32) | (float basicAt: 2).
	exponent := (data >> 52) & 16r7fff.
	^ SmallFloatExponentMin <= exponent and: [ exponent <= SmallFloatExponentMax ]
]

{ #category : #'immediate literals' }
SLVMObjectModel >> isSmallInteger: integer [
	target pointerSize = 4 ifTrue: [
		^ integer between: -1073741824 and: 1073741823
	] ifFalse: [
		^ integer between: -1152921504606846976 and: 1152921504606846975
	]
	
]

{ #category : #'trampoline names' }
SLVMObjectModel >> messageSendTrampoline [
	self subclassResponsibility
]

{ #category : #'trampoline names' }
SLVMObjectModel >> messageSuperSendTrampoline [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SLVMObjectModel >> objectAlignment [
	^ 16
]

{ #category : #'immediate literals' }
SLVMObjectModel >> rotate64Left1: bits [
	^ ((bits << 1) | ((bits >> 63) & 1)) & 16rFFFFFFFFFFFFFFFF
]

{ #category : #'trampoline names' }
SLVMObjectModel >> stackLimitTrampoline [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMObjectModel >> target [
	^ target
]

{ #category : #accessing }
SLVMObjectModel >> target: anObject [
	target := anObject
]

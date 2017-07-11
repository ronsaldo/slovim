Class {
	#name : #SLVMObjectModel,
	#superclass : #SLVMObject,
	#instVars : [
		'target'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #'as yet unclassified' }
SLVMObjectModel >> closureHeaderType [
	^ nil
]

{ #category : #'as yet unclassified' }
SLVMObjectModel >> closureInstantiateFunction [
	^ nil
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
			names: #(objectHeader function environment)
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
	(literalClass includesBehavior: Float) ifTrue: [ ^ self isSmallFloat: literal ].
	(literalClass includesBehavior: Integer) ifTrue: [ ^ self isSmallInteger: literal ].
	(literalClass includesBehavior: UndefinedObject) ifTrue: [ ^ true].
	^ false
]

{ #category : #'immediate literals' }
SLVMObjectModel >> isSmallFloat: float [
	target pointerSize < 8 ifTrue: [ ^ false ].
	self halt
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

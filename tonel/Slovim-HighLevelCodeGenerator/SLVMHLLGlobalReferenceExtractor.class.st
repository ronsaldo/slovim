Class {
	#name : #SLVMHLLGlobalReferenceExtractor,
	#superclass : #SLVMValueVisitor,
	#instVars : [
		'globals',
		'codeGenerator'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLLGlobalReferenceExtractor >> codeGenerator [
	^ codeGenerator
]

{ #category : #accessing }
SLVMHLLGlobalReferenceExtractor >> codeGenerator: anObject [
	codeGenerator := anObject
]

{ #category : #accessing }
SLVMHLLGlobalReferenceExtractor >> globals [
	^ globals
]

{ #category : #accessing }
SLVMHLLGlobalReferenceExtractor >> globals: anObject [
	globals := anObject
]

{ #category : #initialization }
SLVMHLLGlobalReferenceExtractor >> initialize [
	super initialize.
	globals := SLVMOrderedInsertionSet new.
]

{ #category : #processing }
SLVMHLLGlobalReferenceExtractor >> process: anInstruction [
	anInstruction accept: self
]

{ #category : #processing }
SLVMHLLGlobalReferenceExtractor >> visitCall: instruction [
	| functionValue translatedFunction |
	functionValue := instruction functionValue.
	(functionValue isGlobalValue and: [ functionValue isFunction ]) ifTrue: [
		translatedFunction := codeGenerator translateValue: functionValue.
		translatedFunction internedGlobals do: [ :interned | globals add: interned value]
	]
]

{ #category : #processing }
SLVMHLLGlobalReferenceExtractor >> visitGetElementPointer: instruction [
	instruction pointer isGlobalValue ifTrue: [ globals add: instruction pointer ]
]

{ #category : #processing }
SLVMHLLGlobalReferenceExtractor >> visitLoad: instruction [
	instruction variable isGlobalValue ifTrue: [ globals add: instruction variable ]
]

{ #category : #processing }
SLVMHLLGlobalReferenceExtractor >> visitStore: instruction [
	instruction variable isGlobalValue ifTrue: [ globals add: instruction variable ]
]

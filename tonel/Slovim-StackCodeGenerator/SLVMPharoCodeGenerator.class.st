"
I am a code generator for a Pharo image.
"
Class {
	#name : #SLVMPharoCodeGenerator,
	#superclass : #SLVMETreeVisitor,
	#instVars : [
		'compilationTarget',
		'pharoModule',
		'translatedElements'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #accessing }
SLVMPharoCodeGenerator >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMPharoCodeGenerator >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #'as yet unclassified' }
SLVMPharoCodeGenerator >> functionCodeGeneratorClass [
	^ SLVMPharoFunctionCodeGenerator
]

{ #category : #initialization }
SLVMPharoCodeGenerator >> initialize [
	pharoModule := SLVMPharoCompilationModule new.
	translatedElements := IdentityDictionary new.
]

{ #category : #'code generation' }
SLVMPharoCodeGenerator >> translateElement: anElement [
	^ anElement accept: self
]

{ #category : #'code generation' }
SLVMPharoCodeGenerator >> translateModule: anETreeModule [
	anETreeModule elements do: [ :el | self translateElement: el ].
	^ pharoModule
]

{ #category : #visiting }
SLVMPharoCodeGenerator >> visitFunction: aFunction [
	| functionCodeGenerator translatedFunction binding |
	translatedElements at: aFunction ifPresent: [ :incomplete | ^ incomplete ].
	binding := SLVMImageFunctionVariableBinding key: aFunction name value: SLVMIncompletePharoFunction new.
	pharoModule add: binding.
	translatedElements at: aFunction put: binding.
	
	functionCodeGenerator := self functionCodeGeneratorClass new
		compilationTarget: compilationTarget;
		moduleTranslator: self.
	translatedFunction := functionCodeGenerator translateFunction: aFunction.
	binding value: translatedFunction.
	^ binding
]

{ #category : #visiting }
SLVMPharoCodeGenerator >> visitGlobalVariable: aGlobalVariable [
	| binding |
	translatedElements at: aGlobalVariable ifPresent: [ :incomplete | ^ incomplete ].
	binding := aGlobalVariable binding ifNil: [ GlobalVariable key: aGlobalVariable name value: nil].
	pharoModule add: binding.
	
	^ binding
]

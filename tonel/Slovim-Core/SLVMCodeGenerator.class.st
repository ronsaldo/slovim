"
I am the superclass of a code generator for a Slovim module.
"
Class {
	#name : #SLVMCodeGenerator,
	#superclass : #Object,
	#instVars : [
		'optimizationLevel'
	],
	#category : #'Slovim-Core-CodeGeneration'
}

{ #category : #name }
SLVMCodeGenerator class >> codeGeneratorName [
	^ name
]

{ #category : #name }
SLVMCodeGenerator class >> generatorNamed: generatorName [
	self allSubclassesDo: [ :sc |
		(sc isAbstract not and: [ sc codeGeneratorName = generatorName ]) ifTrue: [ ^ sc new]
	].
	self error: 'unknown code generator'
]

{ #category : #testing }
SLVMCodeGenerator class >> isAbstract [
	^ self == SLVMCodeGenerator
]

{ #category : #'code generation' }
SLVMCodeGenerator class >> translateModule: module [
	^ self new translateModule: module
]

{ #category : #'code generation' }
SLVMCodeGenerator class >> translateModule: module exportList: exportList [
	^ self new translateModule: module exportList: exportList
]

{ #category : #'code generation' }
SLVMCodeGenerator class >> translateModule: module function: shaderName [
	^ self translateModule: module exportList: { module globalValues at: shaderName }
]

{ #category : #'code generation' }
SLVMCodeGenerator >> applyOptimizationsIn: ssaModule functionList: functionList [
	| globalOptimization |
	(optimizationLevel = 0 and: [ self isInliningMandatory not ]) ifTrue: [ ^ self ].
	globalOptimization := SLVMOptInline new.
	globalOptimization keepStructuredControlFlow: self needStructuredControlFlow.
	globalOptimization postInlineOptimizations: (ssaModule createFunctionOptimizationPassesForLevel: optimizationLevel).
	globalOptimization passOnFunctions: functionList.
]

{ #category : #testing }
SLVMCodeGenerator >> isInliningMandatory [
	self subclassResponsibility
]

{ #category : #testing }
SLVMCodeGenerator >> needStructuredControlFlow [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMCodeGenerator >> optimizationLevel [
	^ optimizationLevel
]

{ #category : #accessing }
SLVMCodeGenerator >> optimizationLevel: anObject [
	optimizationLevel := anObject
]

{ #category : #'code generation' }
SLVMCodeGenerator >> translateModule: module [
	^ self translateModule: module exportList: module globalValues
]

{ #category : #'code generation' }
SLVMCodeGenerator >> translateModule: module exportList: exportList [
	self subclassResponsibility
]

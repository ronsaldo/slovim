"
I am the superclass of a code generator for a Slovim module.
"
Class {
	#name : #SLVMCodeGenerator,
	#superclass : #Object,
	#instVars : [
		'optimizationLevel',
		'globalOptimization'
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
	(optimizationLevel = 0 and: [ self isInliningMandatory not ]) ifTrue: [ ^ self ].
	globalOptimization ifNil: [
		globalOptimization := SLVMOptInline new.
		globalOptimization keepStructuredControlFlow: self needStructuredControlFlow.
		globalOptimization postInlineOptimizations: (ssaModule createFunctionOptimizationPassesForLevel: optimizationLevel).
	].

	globalOptimization passOnFunctions: functionList.
]

{ #category : #'code generation' }
SLVMCodeGenerator >> applyPassesIn: ssaModule functionList: functionList [
	self applyOptimizationsIn: ssaModule functionList: functionList.
	self usesGCStrategy ifTrue: [ functionList do: #applyGCStrategy ].
	self needSSADestroyed ifTrue: [ 
		SLVMOptDestroySSA passOnFunctions: functionList.
	].
	
]

{ #category : #'code generation' }
SLVMCodeGenerator >> applyPassesInFunction: function [
	globalOptimization ifNotNil: [ globalOptimization passOnFunction: function ].
	self usesGCStrategy ifTrue: [ function applyGCStrategy ].
	self needSSADestroyed ifTrue: [ 
		SLVMOptDestroySSA passOnFunction: function.
	].
	^ function
	
]

{ #category : #initialization }
SLVMCodeGenerator >> initialize [
	super initialize.
	optimizationLevel := 0.
]

{ #category : #testing }
SLVMCodeGenerator >> isInliningMandatory [
	self subclassResponsibility
]

{ #category : #testing }
SLVMCodeGenerator >> needSSADestroyed [
	^ false
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
	^ self translateModule: module exportList: module allGlobalValues
]

{ #category : #'code generation' }
SLVMCodeGenerator >> translateModule: module exportList: exportList [
	self subclassResponsibility
]

{ #category : #testing }
SLVMCodeGenerator >> usesGCStrategy [
	^ false
]

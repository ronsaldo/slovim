"
I am the superclass of a code generator for a Slovim module.
"
Class {
	#name : #SLVMCodeGenerator,
	#superclass : #Object,
	#instVars : [
		'optimizationLevel',
		'globalOptimization',
		'optimizedElements'
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
	^ self translateModule: module exportList: { module globalNamed: shaderName }
]

{ #category : #'code generation' }
SLVMCodeGenerator >> applyOptimizationsIn: ssaModule functionList: functionList [
	(self globalOptimizationForModule: ssaModule) ifNotNil: [ :opt |
		opt passOnFunctions: functionList
	].
]

{ #category : #'code generation' }
SLVMCodeGenerator >> applyPassesIn: ssaModule functionList: functionList [
	| unoptimized |
	unoptimized := functionList.
	optimizedElements ifNotEmpty: [
		unoptimized := functionList reject: [ :el | optimizedElements includes: el ]
	].

	optimizedElements addAll: unoptimized.
	self applyOptimizationsIn: ssaModule functionList: unoptimized.
	self usesGCStrategy ifTrue: [ unoptimized do: #applyGCStrategy ].
	self needSSADestroyed ifTrue: [ 
		SLVMOptDestroySSA passOnFunctions: unoptimized.
	].
	

]

{ #category : #'code generation' }
SLVMCodeGenerator >> applyPassesInFunction: function [
	(optimizedElements includes: function) ifTrue: [ ^ function ].
	
	optimizedElements add: function.
	(self globalOptimizationForModule: function module) ifNotNil: [ :opt |
		opt passOnFunction: function
	].

	self usesGCStrategy ifTrue: [ function applyGCStrategy ].
	self needSSADestroyed ifTrue: [ 
		SLVMOptDestroySSA passOnFunction: function.
	].
	^ function
	
]

{ #category : #'code generation' }
SLVMCodeGenerator >> globalOptimizationForModule: ssaModule [
	(optimizationLevel = 0 and: [ self isInliningMandatory not ]) ifTrue: [ ^ nil ].
	ssaModule disableSLVMOptimizations ifTrue: [ ^ nil ].
	
	^ globalOptimization ifNil: [
		globalOptimization := SLVMOptInline new.
		globalOptimization inliningMandatory: self isInliningMandatory.
		globalOptimization keepStructuredControlFlow: self needStructuredControlFlow.
		globalOptimization postInlineOptimizations: (ssaModule createFunctionOptimizationPassesForLevel: optimizationLevel).
	].

]

{ #category : #initialization }
SLVMCodeGenerator >> initialize [
	super initialize.
	optimizationLevel := 0.
	optimizedElements := IdentitySet new.
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

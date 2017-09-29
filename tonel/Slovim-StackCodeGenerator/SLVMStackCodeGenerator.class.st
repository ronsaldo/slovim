Class {
	#name : #SLVMStackCodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'target',
		'translatedElements',
		'etreeModule'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #'as yet unclassified' }
SLVMStackCodeGenerator >> isInliningMandatory [
	^ false
]

{ #category : #testing }
SLVMStackCodeGenerator >> needSSADestroyed [
	^ true
]

{ #category : #accessing }
SLVMStackCodeGenerator >> target [
	^ target
]

{ #category : #accessing }
SLVMStackCodeGenerator >> target: anObject [
	target := anObject
]

{ #category : #'code generation' }
SLVMStackCodeGenerator >> translateModule: module exportList: exportList [
	self applyPassesIn: module functionList: (exportList select: #isFunction).
	etreeModule := SLVMETreeModule new.
	translatedElements := Dictionary new.
	
	exportList do: [ :element |
		self translateModuleElement: element
	].
	^ etreeModule
]

{ #category : #'code generation' }
SLVMStackCodeGenerator >> translateModuleElement: element [
	^ element accept: self
]

{ #category : #visiting }
SLVMStackCodeGenerator >> visitFunction: aFunction [
	| expressionTreeFunction |
	translatedElements at: aFunction ifPresent: [ :incomplete | ^ incomplete ].

	expressionTreeFunction := SLVMETreeFunction new.
	expressionTreeFunction name: aFunction name.
	
	etreeModule add: expressionTreeFunction.
	translatedElements at: aFunction put: expressionTreeFunction.
	
	SLVMStackFunctionCodeGenerator new
		moduleCodeGenerator: self;
		translateFunction: aFunction into: expressionTreeFunction.
		
]

Class {
	#name : #SLVMSAsmCodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'target',
		'classVariableClassMap',
		'sasmModule',
		'translatedElements'
	],
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> convertVisibility: visibility [
	^ visibility
]

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> isInliningMandatory [
	^ false
]

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> needSSADestroyed [
	^ true
]

{ #category : #accessing }
SLVMSAsmCodeGenerator >> target [
	^ target
]

{ #category : #accessing }
SLVMSAsmCodeGenerator >> target: anObject [
	target := anObject
]

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> translateModule: module [
	| packageRegistration |
	module packages ifNotEmpty: [
		packageRegistration := module generatePackageRegistration.
	].

	^ self translateModule: module exportList: module allGlobalValues packageRegistration: packageRegistration
]

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> translateModule: module exportList: exportList [
	^ self translateModule: module exportList: exportList packageRegistration: nil
]

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> translateModule: module exportList: exportList packageRegistration: packageRegistration [
	classVariableClassMap := module classVariableClassMap.
	self applyPassesIn: module functionList: exportList.
	sasmModule := SAsmModule new target: target target.
	translatedElements := Dictionary new.

	exportList do: [ :element |
		self translateModuleElement: element
	].

	packageRegistration ifNotNil: [
		sasmModule packageRegistration: (self translateModuleElement: packageRegistration)
	].

	^ sasmModule
]

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> translateModuleElement: element [
	^ element accept: self
]

{ #category : #'as yet unclassified' }
SLVMSAsmCodeGenerator >> visitFunction: aFunction [
	| functionCodeGenerator result |
	translatedElements at: aFunction ifPresent: [ :incomplete | ^ incomplete ].
	
	result := SAsmFunction new
		name: aFunction name;
		target: sasmModule target;
		visibility: (self convertVisibility: aFunction visibility);
		yourself.
	translatedElements at: aFunction put: result.
	sasmModule addElement: result.

	functionCodeGenerator := SLVMSAsmFunctionCodeGenerator new.
	functionCodeGenerator
		target: target;
		moduleTranslator: self;
		generateFunction: aFunction into: result.
		
	^ result
		
]

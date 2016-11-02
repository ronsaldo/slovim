"
This is a nop code generator.
"
Class {
	#name : #SLVMSSACodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'needStructuredControlFlow',
		'isInliningMandatory'
	],
	#category : #'Slovim-Core-CodeGeneration'
}

{ #category : #name }
SLVMSSACodeGenerator class >> codeGeneratorName [
	^ #ssa
]

{ #category : #initialization }
SLVMSSACodeGenerator >> initialize [
	super initialize.
	needStructuredControlFlow := false.
	isInliningMandatory := false.
]

{ #category : #accessing }
SLVMSSACodeGenerator >> isInliningMandatory [
	^ isInliningMandatory
]

{ #category : #accessing }
SLVMSSACodeGenerator >> isInliningMandatory: anObject [
	isInliningMandatory := anObject
]

{ #category : #accessing }
SLVMSSACodeGenerator >> needStructuredControlFlow [
	^ needStructuredControlFlow
]

{ #category : #accessing }
SLVMSSACodeGenerator >> needStructuredControlFlow: anObject [
	needStructuredControlFlow := anObject
]

{ #category : #'code generation' }
SLVMSSACodeGenerator >> translateModule: ssaModule exportList: exportList [
	self applyPassesIn: ssaModule functionList: exportList.
	^ ssaModule
]

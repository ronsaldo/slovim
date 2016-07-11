"
I am the superclass of a code generator for a Slovim module.
"
Class {
	#name : #SLVMCodeGenerator,
	#superclass : #Object,
	#category : #'Slovim-Core-CodeGeneration'
}

{ #category : #name }
SLVMCodeGenerator class >> codeGeneratorName [
	^ name
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
SLVMCodeGenerator >> translateModule: module [
	self subclassResponsibility
]

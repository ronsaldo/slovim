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
SLVMCodeGenerator class >> translateModule: module exportList: exportList [
	^ self new translateModule: module exportList: exportList
]

{ #category : #'code generation' }
SLVMCodeGenerator class >> translateModule: module function: shaderName [
	^ self translateModule: module exportList: { module globalValues at: shaderName }
]

{ #category : #'code generation' }
SLVMCodeGenerator >> translateModule: module [
	^ self translateModule: module exportList: module globalValues
]

{ #category : #'code generation' }
SLVMCodeGenerator >> translateModule: module exportList: exportList [
	self subclassResponsibility
]

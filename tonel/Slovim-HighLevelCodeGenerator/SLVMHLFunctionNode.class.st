Class {
	#name : #SLVMHLFunctionNode,
	#superclass : #SLVMHLCodeNode,
	#instVars : [
		'name',
		'type',
		'arguments',
		'dynamicLiterals',
		'locals',
		'body',
		'internedGlobals',
		'shaderType'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLFunctionNode >> arguments [
	^ arguments
]

{ #category : #accessing }
SLVMHLFunctionNode >> arguments: anObject [
	arguments := anObject
]

{ #category : #accessing }
SLVMHLFunctionNode >> body [
	^ body
]

{ #category : #accessing }
SLVMHLFunctionNode >> body: anObject [
	body := anObject
]

{ #category : #accessing }
SLVMHLFunctionNode >> dynamicLiterals [
	^ dynamicLiterals
]

{ #category : #accessing }
SLVMHLFunctionNode >> dynamicLiterals: anObject [
	dynamicLiterals := anObject
]

{ #category : #initialization }
SLVMHLFunctionNode >> initialize [
	super initialize.
	arguments := #().
	internedGlobals := #().
	locals := OrderedCollection new.
]

{ #category : #accessing }
SLVMHLFunctionNode >> internedGlobals [
	^ internedGlobals
]

{ #category : #accessing }
SLVMHLFunctionNode >> internedGlobals: anObject [
	internedGlobals := anObject
]

{ #category : #initialization }
SLVMHLFunctionNode >> locals [
	^ locals
]

{ #category : #accessing }
SLVMHLFunctionNode >> name [
	^ name
]

{ #category : #accessing }
SLVMHLFunctionNode >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMHLFunctionNode >> printOn: aStream [
	aStream nextPutAll: '(function '; print: name; space; print: type; nextPut: $)
]

{ #category : #accessing }
SLVMHLFunctionNode >> shaderType [
	^ shaderType
]

{ #category : #accessing }
SLVMHLFunctionNode >> shaderType: anObject [
	shaderType := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLFunctionNode >> translateValueWith: translator [
	^ translator translateHLFunctionValue: self
]

{ #category : #'as yet unclassified' }
SLVMHLFunctionNode >> translateWith: translator [
	^ translator translateHLFunction: self
]

{ #category : #accessing }
SLVMHLFunctionNode >> type [
	^ type
]

{ #category : #accessing }
SLVMHLFunctionNode >> type: anObject [
	type := anObject
]

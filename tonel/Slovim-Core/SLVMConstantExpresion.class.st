Class {
	#name : #SLVMConstantExpresion,
	#superclass : #SLVMConstant,
	#instVars : [
		'type',
		'parameters'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #testing }
SLVMConstantExpresion class >> isAbstract [
	^ self == SLVMConstantExpresion
]

{ #category : #printing }
SLVMConstantExpresion >> asSExpression [
	^ { self mnemonic . type asSExpression . parameters collect: [ :each | each asSExpression ] }
]

{ #category : #accessing }
SLVMConstantExpresion >> parameters [
	^ parameters
]

{ #category : #accessing }
SLVMConstantExpresion >> parameters: anArrayOfParameters [
	parameters := anArrayOfParameters

]

{ #category : #accessing }
SLVMConstantExpresion >> type [
	^ type
]

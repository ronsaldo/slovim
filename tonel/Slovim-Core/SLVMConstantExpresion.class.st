Class {
	#name : #SLVMConstantExpresion,
	#superclass : #SLVMConstant,
	#instVars : [
		'type',
		'parameters'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMConstantExpresion >> mnemonic [
	self subclassResponsibility
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

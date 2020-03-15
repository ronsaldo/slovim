Class {
	#name : #SLVMConstantExpresionCast,
	#superclass : #SLVMConstantExpresion,
	#category : #'Slovim-Core-SSA'
}

{ #category : #testing }
SLVMConstantExpresionCast class >> isAbstract [
	^ self == SLVMConstantExpresionCast
]

{ #category : #accessing }
SLVMConstantExpresionCast >> source [
	^ self value
]

{ #category : #accessing }
SLVMConstantExpresionCast >> value [
	^ parameters first
]

{ #category : #'as yet unclassified' }
SLVMConstantExpresionCast >> value: aValue targetType: aTargetType [
	self parameters: { aValue }.
	type := aTargetType
]

Class {
	#name : #SLVMConstantBinaryExpresion,
	#superclass : #SLVMConstantExpresion,
	#category : #'Slovim-Core-SSA'
}

{ #category : #'initialize-release' }
SLVMConstantBinaryExpresion class >> left: left right: right [
	^ self new left: left right: right
]

{ #category : #accessing }
SLVMConstantBinaryExpresion >> left [
	 ^ parameters first
]

{ #category : #'initialize-release' }
SLVMConstantBinaryExpresion >> left: left right: right [
	self assert: left type = right type.
	type := left type.
	self parameters: { left . right }
]

{ #category : #accessing }
SLVMConstantBinaryExpresion >> right [
	 ^ parameters second
]

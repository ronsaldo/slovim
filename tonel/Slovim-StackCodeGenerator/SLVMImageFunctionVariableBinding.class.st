"
I represent a variable binding for an in image function.
"
Class {
	#name : #SLVMImageFunctionVariableBinding,
	#superclass : #LiteralVariable,
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #testing }
SLVMImageFunctionVariableBinding >> isFunctionBinding [
	^ true
]

Class {
	#name : #SLVMETreeConstantDynamicLiteral,
	#superclass : #SLVMETreeConstant,
	#instVars : [
		'value'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeConstantDynamicLiteral >> accept: aVisitor [
	^ aVisitor visitFunctionDynamicLiteral: self
]

{ #category : #'public access' }
SLVMETreeConstantDynamicLiteral >> evaluate [
	^ value
]

{ #category : #testing }
SLVMETreeConstantDynamicLiteral >> isFunctionDynamicLiteral [
	^ true
]

{ #category : #printing }
SLVMETreeConstantDynamicLiteral >> prettyPrintOn: aStream [
	aStream nextPut:$(; putKeyword: #dynlit; space; print: value; nextPut:$)
]

{ #category : #accessing }
SLVMETreeConstantDynamicLiteral >> value [
	^ value
]

{ #category : #accessing }
SLVMETreeConstantDynamicLiteral >> value: anObject [
	value := anObject
]

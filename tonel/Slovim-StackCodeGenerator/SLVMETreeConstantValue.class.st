Class {
	#name : #SLVMETreeConstantValue,
	#superclass : #SLVMETreeConstant,
	#instVars : [
		'value'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeConstantValue >> accept: aVisitor [
	^ aVisitor visitConstantValue: self
]

{ #category : #testing }
SLVMETreeConstantValue >> isConstantValue [
	^ true
]

{ #category : #printing }
SLVMETreeConstantValue >> prettyPrintOn: aStream [
	aStream nextPut:$(; putKeyword: #constant; space; print: value; nextPut:$)
]

{ #category : #accessing }
SLVMETreeConstantValue >> value [
	^ value
]

{ #category : #accessing }
SLVMETreeConstantValue >> value: anObject [
	value := anObject
]

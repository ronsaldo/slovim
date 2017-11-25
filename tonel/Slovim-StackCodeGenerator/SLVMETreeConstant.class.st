Class {
	#name : #SLVMETreeConstant,
	#superclass : #SLVMETreeValue,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #testing }
SLVMETreeConstant >> isConstant [
	^ true
]

{ #category : #testing }
SLVMETreeConstant >> isPureExpression [
	^ true
]

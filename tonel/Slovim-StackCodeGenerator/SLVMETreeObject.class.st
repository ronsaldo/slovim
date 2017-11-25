Class {
	#name : #SLVMETreeObject,
	#superclass : #Object,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #testing }
SLVMETreeObject >> isGlobalVariable [
	^ false
]

{ #category : #testing }
SLVMETreeObject >> isPureExpression [
	^ false
]

{ #category : #testing }
SLVMETreeObject >> isStatement [
	^ false
]

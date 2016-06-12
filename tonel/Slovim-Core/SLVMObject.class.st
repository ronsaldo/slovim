Class {
	#name : #SLVMObject,
	#superclass : #Object,
	#category : #'Slovim-Core'
}

{ #category : #testing }
SLVMObject >> isSSAValue [
	^ false
]

{ #category : #testing }
SLVMObject >> isSlovimType [
	^ false
]

{ #category : #testing }
SLVMObject >> isType [
	^ false
]

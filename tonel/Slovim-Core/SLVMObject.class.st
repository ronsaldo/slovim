"
I am a SLVM object. I add some testing methods.
"
Class {
	#name : #SLVMObject,
	#superclass : #Object,
	#category : #'Slovim-Core'
}

{ #category : #testing }
SLVMObject >> isSLVMObject [
	^ true
]

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

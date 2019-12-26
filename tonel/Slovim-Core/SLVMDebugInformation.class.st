Class {
	#name : #SLVMDebugInformation,
	#superclass : #SLVMObject,
	#category : #'Slovim-Core-Debug'
}

{ #category : #visiting }
SLVMDebugInformation >> accept: visitor [
	^ self subclassResponsibility
]

{ #category : #testing }
SLVMDebugInformation >> isDebugDerivedType [
	^ false
]

{ #category : #testing }
SLVMDebugInformation >> isDebugType [
	^ false
]

{ #category : #accessing }
SLVMDebugInformation >> scope [
	^ nil
]

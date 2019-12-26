Class {
	#name : #SLVMDebugInformation,
	#superclass : #SLVMObject,
	#category : #'Slovim-Core-Debug'
}

{ #category : #visiting }
SLVMDebugInformation >> accept: visitor [
	^ self subclassResponsibility
]

{ #category : #accessing }
SLVMDebugInformation >> scope [
	^ nil
]

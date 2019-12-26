Class {
	#name : #SLVMDebugNamespace,
	#superclass : #SLVMDebugScope,
	#category : #'Slovim-Core-Debug'
}

{ #category : #visiting }
SLVMDebugNamespace >> accept: visitor [
	^ visitor visitDebugNamespace: self
]

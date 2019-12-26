Class {
	#name : #SLVMDebugLexicalScope,
	#superclass : #SLVMDebugLocalScope,
	#category : #'Slovim-Core-Debug'
}

{ #category : #visiting }
SLVMDebugLexicalScope >> accept: visitor [
	^ visitor visitDebugLexicalScope: self
]

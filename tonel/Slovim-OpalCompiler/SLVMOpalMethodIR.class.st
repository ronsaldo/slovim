Class {
	#name : #SLVMOpalMethodIR,
	#superclass : #Object,
	#instVars : [
		'function'
	],
	#category : #'Slovim-OpalCompiler'
}

{ #category : #results }
SLVMOpalMethodIR >> compiledMethodWith: methodTrailer [
	^ function
]

{ #category : #accessing }
SLVMOpalMethodIR >> function [
	^ function
]

{ #category : #accessing }
SLVMOpalMethodIR >> function: anObject [
	function := anObject
]

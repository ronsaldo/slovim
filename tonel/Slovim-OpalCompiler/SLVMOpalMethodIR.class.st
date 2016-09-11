Class {
	#name : #SLVMOpalMethodIR,
	#superclass : #Object,
	#instVars : [
		'function'
	],
	#category : #'Slovim-OpalCompiler-Translator'
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

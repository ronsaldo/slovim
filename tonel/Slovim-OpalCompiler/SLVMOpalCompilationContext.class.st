Class {
	#name : #SLVMOpalCompilationContext,
	#superclass : #CompilationContext,
	#instVars : [
		'compilationTarget'
	],
	#category : #'Slovim-OpalCompiler-Translator'
}

{ #category : #accessing }
SLVMOpalCompilationContext >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMOpalCompilationContext >> compilationTarget: anObject [
	compilationTarget := anObject
]

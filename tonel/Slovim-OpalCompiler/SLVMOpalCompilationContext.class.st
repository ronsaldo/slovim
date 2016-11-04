Class {
	#name : #SLVMOpalCompilationContext,
	#superclass : #CompilationContext,
	#instVars : [
		'module',
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

{ #category : #accessing }
SLVMOpalCompilationContext >> module [
	^ module
]

{ #category : #accessing }
SLVMOpalCompilationContext >> module: anObject [
	module := anObject
]

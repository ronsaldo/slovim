Class {
	#name : #SLVMLirCompiledMethod,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'entryPoint'
	],
	#classVars : [
		'KernelClassMapping'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Image'
}

{ #category : #accessing }
SLVMLirCompiledMethod >> entryPoint [
	^ entryPoint
]

{ #category : #accessing }
SLVMLirCompiledMethod >> entryPoint: anObject [
	entryPoint := anObject
]

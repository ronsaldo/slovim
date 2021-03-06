Class {
	#name : #SLVMLirCompiledMethod,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'entryPoint',
		'flags',
		'argumentDescriptor',
		'annotations'
	],
	#classVars : [
		'KernelClassMapping'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Image'
}

{ #category : #accessing }
SLVMLirCompiledMethod >> annotations [
	^ annotations
]

{ #category : #accessing }
SLVMLirCompiledMethod >> annotations: anObject [
	annotations := anObject
]

{ #category : #accessing }
SLVMLirCompiledMethod >> argumentDescriptor [
	^ argumentDescriptor
]

{ #category : #accessing }
SLVMLirCompiledMethod >> argumentDescriptor: anObject [
	argumentDescriptor := anObject
]

{ #category : #accessing }
SLVMLirCompiledMethod >> entryPoint [
	^ entryPoint
]

{ #category : #accessing }
SLVMLirCompiledMethod >> entryPoint: anObject [
	entryPoint := anObject
]

{ #category : #accessing }
SLVMLirCompiledMethod >> flags [
	^ flags
]

{ #category : #accessing }
SLVMLirCompiledMethod >> flags: anObject [
	flags := anObject
]

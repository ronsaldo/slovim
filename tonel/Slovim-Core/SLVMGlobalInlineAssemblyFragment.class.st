Class {
	#name : #SLVMGlobalInlineAssemblyFragment,
	#superclass : #SLVMObject,
	#instVars : [
		'architecture',
		'language',
		'source'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #accessing }
SLVMGlobalInlineAssemblyFragment >> architecture [
	^ architecture
]

{ #category : #accessing }
SLVMGlobalInlineAssemblyFragment >> architecture: anObject [
	architecture := anObject
]

{ #category : #accessing }
SLVMGlobalInlineAssemblyFragment >> language [
	^ language
]

{ #category : #accessing }
SLVMGlobalInlineAssemblyFragment >> language: anObject [
	language := anObject
]

{ #category : #accessing }
SLVMGlobalInlineAssemblyFragment >> source [
	^ source
]

{ #category : #accessing }
SLVMGlobalInlineAssemblyFragment >> source: anObject [
	source := anObject
]

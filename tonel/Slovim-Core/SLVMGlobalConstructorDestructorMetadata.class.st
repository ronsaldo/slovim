Class {
	#name : #SLVMGlobalConstructorDestructorMetadata,
	#superclass : #SLVMObject,
	#instVars : [
		'global',
		'function',
		'priority'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #accessing }
SLVMGlobalConstructorDestructorMetadata >> function [
	^ function
]

{ #category : #accessing }
SLVMGlobalConstructorDestructorMetadata >> function: anObject [
	function := anObject
]

{ #category : #accessing }
SLVMGlobalConstructorDestructorMetadata >> global [
	^ global
]

{ #category : #accessing }
SLVMGlobalConstructorDestructorMetadata >> global: anObject [
	global := anObject
]

{ #category : #accessing }
SLVMGlobalConstructorDestructorMetadata >> priority [
	^ priority
]

{ #category : #accessing }
SLVMGlobalConstructorDestructorMetadata >> priority: anObject [
	priority := anObject
]

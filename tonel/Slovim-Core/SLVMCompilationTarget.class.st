Class {
	#name : #SLVMCompilationTarget,
	#superclass : #SLVMObject,
	#instVars : [
		'dynamicObjectType'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #accessing }
SLVMCompilationTarget >> dynamicObjectType [
	^ dynamicObjectType ifNil: [ dynamicObjectType := SLVMDynamicObjectType new size: self pointerSize ]
]

{ #category : #convenience }
SLVMCompilationTarget >> generateLowLevelModule: aModule [
	^ self lowLevelCodeGeneratorClass translateModule: aModule
]

{ #category : #accessing }
SLVMCompilationTarget >> lowLevelCodeGeneratorClass [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMCompilationTarget >> pointerAlignment [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMCompilationTarget >> pointerSize [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMCompilationTarget >> referenceAlignment [
	^ self pointerAlignment
]

{ #category : #accessing }
SLVMCompilationTarget >> referenceSize [
	^ self pointerSize
]

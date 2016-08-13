Class {
	#name : #SLVMCompilationTarget,
	#superclass : #SLVMObject,
	#category : #'Slovim-Core-Type'
}

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

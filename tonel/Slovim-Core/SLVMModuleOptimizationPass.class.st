Class {
	#name : #SLVMModuleOptimizationPass,
	#superclass : #SLVMOptimizationPass,
	#category : #'Slovim-Core-Optimizations'
}

{ #category : #'as yet unclassified' }
SLVMModuleOptimizationPass class >> passOnModule: aModule [
	^ self new passOnModule: aModule
]

{ #category : #'as yet unclassified' }
SLVMModuleOptimizationPass >> passOnModule: aModule [
	self subclassResponsibility
]

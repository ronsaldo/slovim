Class {
	#name : #SLVMOptimizationPass,
	#superclass : #Object,
	#category : #'Slovim-Core-SSA'
}

{ #category : #applying }
SLVMOptimizationPass class >> passOnFunction: aFunction [
	^ self new passOnFunction: aFunction
]

{ #category : #applying }
SLVMOptimizationPass >> passOnFunction: aFunction [
	self subclassResponsibility
]

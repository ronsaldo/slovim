Class {
	#name : #SLVMOptimizationPass,
	#superclass : #Object,
	#category : #'Slovim-Core-Optimizations'
}

{ #category : #applying }
SLVMOptimizationPass class >> passOnFunction: aFunction [
	^ self new passOnFunction: aFunction
]

{ #category : #applying }
SLVMOptimizationPass class >> passOnFunctions: aFunction [
	^ self new passOnFunctions: aFunction
]

{ #category : #applying }
SLVMOptimizationPass >> passOnFunction: aFunction [
	self subclassResponsibility
]

{ #category : #applying }
SLVMOptimizationPass >> passOnFunctions: aCollectionOfFunctions [
	aCollectionOfFunctions do: [ :function | self passOnFunction: function ]
]

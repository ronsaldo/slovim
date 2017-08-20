Class {
	#name : #SLVMFunctionGCNoneLoweringPass,
	#superclass : #SLVMFunctionGCLoweringPass,
	#category : #'Slovim-Core-GC'
}

{ #category : #'as yet unclassified' }
SLVMFunctionGCNoneLoweringPass class >> gcName [
	^ #none
]

{ #category : #applying }
SLVMFunctionGCNoneLoweringPass >> passOnFunction: aFunction [
]

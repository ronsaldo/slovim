Class {
	#name : #SLVMFunctionGCLoweringPass,
	#superclass : #SLVMFunctionOptimizationPass,
	#category : #'Slovim-Core-GC'
}

{ #category : #'as yet unclassified' }
SLVMFunctionGCLoweringPass class >> gcName [
	^ nil
]

{ #category : #'as yet unclassified' }
SLVMFunctionGCLoweringPass class >> gcNamed: aGCName [
	self allSubclassesDo: [ :sc |
		sc gcName = aGCName ifTrue: [ ^ sc ].
	].

	self error: 'Unknown GC strategy name'
]

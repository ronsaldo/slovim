Class {
	#name : #SLVMModule,
	#superclass : #SLVMObject,
	#instVars : [
		'globalValues'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #adding }
SLVMModule >> add: aGlobalValue [
	globalValues at: aGlobalValue name put: aGlobalValue
]

{ #category : #'as yet unclassified' }
SLVMModule >> applyFunctionOptimizationPasses: passes [
	globalValues valuesDo: [ :val | val isFunction ifTrue: [ val applyFunctionOptimizationPasses: passes ] ]
]

{ #category : #'as yet unclassified' }
SLVMModule >> createFunctionOptimizationPassesForLevel: optimizationLevel [
	| passes |
	passes := OrderedCollection new.
	passes addAll: {
		SLVMOptPromoteAllocas.
		SLVMOptBasicOptimizations.
	}.
	
	"Add lot more passes depending on the optimization level."
	^ passes asArray
]

{ #category : #adding }
SLVMModule >> globalNamed: aSymbol [
	^ globalValues at: aSymbol
]

{ #category : #accessing }
SLVMModule >> globalValues [
	^ globalValues
]

{ #category : #initialization }
SLVMModule >> initialize [
	globalValues := OrderedDictionary new.
]

{ #category : #'as yet unclassified' }
SLVMModule >> optimizeWithLevel: optimizationLevel [
	| functionOptimizationPasses |
	optimizationLevel = 0 ifTrue: [ ^ self ].
	functionOptimizationPasses := self createFunctionOptimizationPassesForLevel: optimizationLevel.
	self applyFunctionOptimizationPasses: functionOptimizationPasses.
]

{ #category : #printing }
SLVMModule >> printOn: aStream [
	globalValues values do: [ :val | val fullPrintOn: aStream ].

]

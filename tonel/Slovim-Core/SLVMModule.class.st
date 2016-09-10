Class {
	#name : #SLVMModule,
	#superclass : #SLVMObject,
	#instVars : [
		'compilationTarget',
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

{ #category : #accessing }
SLVMModule >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMModule >> compilationTarget: anObject [
	compilationTarget := anObject
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

{ #category : #building }
SLVMModule >> functionName: name arguments: arguments returnType: returnType [
	| function |
	function := SLVMFunction pointerSize: compilationTarget pointerSize name: name functionType: (SLVMFunctionType arguments: arguments returnType: returnType).
	function compilationTarget: compilationTarget.
	
	self add: function.
	^ function
]

{ #category : #building }
SLVMModule >> functionName: name fixedArguments: arguments returnType: returnType [
	| function functionType |
	functionType := (SLVMFunctionType arguments: arguments returnType: returnType) variadic: true.
	function := SLVMFunction pointerSize: compilationTarget pointerSize name: name functionType: functionType.
	function compilationTarget: compilationTarget.
	self add: function.
	^ function
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

{ #category : #types }
SLVMModule >> pointerTypeFor: baseType [
	^ self pointerTypeFor: baseType  storage: SLVMType genericStorage
]

{ #category : #types }
SLVMModule >> pointerTypeFor: baseType storage: storage [
	^ SLVMPointerType size: compilationTarget pointerSize baseType: baseType storage: storage
]

{ #category : #printing }
SLVMModule >> printOn: aStream [
	globalValues values do: [ :val | val fullPrintOn: aStream ].

]

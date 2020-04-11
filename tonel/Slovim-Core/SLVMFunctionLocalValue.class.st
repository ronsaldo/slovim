"
I represent a value that is only valid in the local scope of a function.
"
Class {
	#name : #SLVMFunctionLocalValue,
	#superclass : #SLVMValue,
	#instVars : [
		'debugInformation',
		'debugSourceLocation',
		'instructionReferences',
		'localValueIndex',
		'localValueIndexComputationCount',
		'function',
		'name'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #testing }
SLVMFunctionLocalValue class >> isAbstract [
	^ self == SLVMFunctionLocalValue
]

{ #category : #adding }
SLVMFunctionLocalValue >> addInstructionReference: anInstruction [
	instructionReferences add: anInstruction
]

{ #category : #printing }
SLVMFunctionLocalValue >> asFullSExpression [
	self subclassResponsibility
]

{ #category : #printing }
SLVMFunctionLocalValue >> asSExpression [
	^ { #local . self validLocalValueIndex . name }
]

{ #category : #accessing }
SLVMFunctionLocalValue >> debugInformation [
	^ debugInformation
]

{ #category : #accessing }
SLVMFunctionLocalValue >> debugInformation: anObject [
	debugInformation := anObject
]

{ #category : #accessing }
SLVMFunctionLocalValue >> debugSourceLocation [
	^ debugSourceLocation
]

{ #category : #accessing }
SLVMFunctionLocalValue >> debugSourceLocation: anObject [
	debugSourceLocation := anObject
]

{ #category : #accessing }
SLVMFunctionLocalValue >> function [
	^ function
]

{ #category : #accessing }
SLVMFunctionLocalValue >> function: anObject [
	function := anObject.
	localValueIndex := nil.
]

{ #category : #testing }
SLVMFunctionLocalValue >> hasAnonName [
	^ name isNil
]

{ #category : #testing }
SLVMFunctionLocalValue >> hasReferences [
	^ instructionReferences isNotEmpty
]

{ #category : #initialization }
SLVMFunctionLocalValue >> initialize [
	instructionReferences := OrderedCollection new.
]

{ #category : #accessing }
SLVMFunctionLocalValue >> instructionReferences [
	^ instructionReferences
]

{ #category : #testing }
SLVMFunctionLocalValue >> isFunctionLocalValue [
	^ true
]

{ #category : #accessing }
SLVMFunctionLocalValue >> localValueIndex [
	^ localValueIndex
]

{ #category : #accessing }
SLVMFunctionLocalValue >> localValueIndex: anObject [
	localValueIndex := anObject
]

{ #category : #accessing }
SLVMFunctionLocalValue >> localValueIndexComputationCount [
	^ localValueIndexComputationCount
]

{ #category : #accessing }
SLVMFunctionLocalValue >> localValueIndexComputationCount: anObject [
	localValueIndexComputationCount := anObject
]

{ #category : #accessing }
SLVMFunctionLocalValue >> name [
	^ name
]

{ #category : #accessing }
SLVMFunctionLocalValue >> name: anObject [
	name := anObject
]

{ #category : #copying }
SLVMFunctionLocalValue >> postCopy [
	super postCopy.
	function := nil.
	localValueIndex := nil.
	instructionReferences := OrderedCollection new.
]

{ #category : #printing }
SLVMFunctionLocalValue >> printOn: aStream [
	aStream nextPut: $%; print: self validLocalValueIndex.
	name ifNotNil: [
		aStream nextPut: $:; print: name
	]
]

{ #category : #adding }
SLVMFunctionLocalValue >> removeInstructionReference: anInstruction [
	instructionReferences removeAllSuchThat: [:el | el == anInstruction]
]

{ #category : #'as yet unclassified' }
SLVMFunctionLocalValue >> validLocalValueIndex [
	self function ifNil: [ ^ 0 ] ifNotNil: [ :f |
		(localValueIndex isNil or: [localValueIndexComputationCount ~~ f localValueIndexComputationCount]) ifTrue: [
			f recomputeLocalValueIndices.
		]
	].
	
	^ localValueIndex
]

{ #category : #accessing }
SLVMFunctionLocalValue >> validName [
	^ name ifNil: [ #anon ]
]

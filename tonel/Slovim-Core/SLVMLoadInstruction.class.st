Class {
	#name : #SLVMLoadInstruction,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'volatile'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMLoadInstruction class >> mnemonic [
	^ #load
]

{ #category : #accessing }
SLVMLoadInstruction class >> variable: variableReference [
	^ self new variable: variableReference
]

{ #category : #visitor }
SLVMLoadInstruction >> accept: aVisitor [
	^ aVisitor visitLoad: self
]

{ #category : #'as yet unclassified' }
SLVMLoadInstruction >> createdWithMnemonic: theMnemonic decodedType: theDecodedType [
	super createdWithMnemonic: theMnemonic decodedType: theDecodedType.
	type := theDecodedType.
]

{ #category : #'basic optimizations' }
SLVMLoadInstruction >> foldConstant [
	| var |
	var := self variable.
	(var isGlobalValue and: [var isGlobalVariable and: [var readOnly]]) ifTrue: [ 
		var initialValue ifNotNil: [ :constant | ^ constant ]
	].
	
	^ super foldConstant
]

{ #category : #initialization }
SLVMLoadInstruction >> initialize [
	super initialize.
	volatile := false.
]

{ #category : #testing }
SLVMLoadInstruction >> isLoad [
	^ true
]

{ #category : #testing }
SLVMLoadInstruction >> isPureInstruction [
	"Remove non-volatile loads without references."
	^ volatile not and: [self hasReferences not]
]

{ #category : #accessing }
SLVMLoadInstruction >> signature [
	^ super signature , { volatile }
]

{ #category : #accessing }
SLVMLoadInstruction >> type [
	^ type
]

{ #category : #accessing }
SLVMLoadInstruction >> variable [
	^ parameters first
]

{ #category : #accessing }
SLVMLoadInstruction >> variable: variableReference [
	| refType |
	self parameters: { variableReference }.
	refType := variableReference type.
	self assert: refType isPointerType.
	type := refType baseType.
]

{ #category : #accessing }
SLVMLoadInstruction >> volatile [
	^ volatile
]

{ #category : #accessing }
SLVMLoadInstruction >> volatile: anObject [
	volatile := anObject
]

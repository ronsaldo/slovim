Class {
	#name : #SLVMInstantiateClosure,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'closureType'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMInstantiateClosure class >> definition: definition captures: captures [
	^ self new definition: definition captures: captures
]

{ #category : #printing }
SLVMInstantiateClosure class >> mnemonic [
	^ #instantiateClosure
]

{ #category : #printing }
SLVMInstantiateClosure >> accept: aVisitor [
	^ aVisitor visitInstantiateClosure: self
]

{ #category : #enumerating }
SLVMInstantiateClosure >> allModuleInstructionsDo: aBlock [
	aBlock value: self.
	self definition allModuleInstructionsDo: aBlock
]

{ #category : #accessing }
SLVMInstantiateClosure >> captures [
	^ parameters allButFirst
]

{ #category : #accessing }
SLVMInstantiateClosure >> childrenNodes [
	^ { self definition }
]

{ #category : #accessing }
SLVMInstantiateClosure >> closureType [
	^ closureType
]

{ #category : #'as yet unclassified' }
SLVMInstantiateClosure >> createdWithMnemonic: theMnemonic decodedType: theDecodedType [
	super createdWithMnemonic: theMnemonic decodedType: theDecodedType.
	type := theDecodedType.
]

{ #category : #accessing }
SLVMInstantiateClosure >> definition [
	^ parameters first
]

{ #category : #construction }
SLVMInstantiateClosure >> definition: definition captures: captures [
	| functionType captureTypes |
	self parameters: { definition } , captures.
	self assert: definition isClosureDefinition.
	self assert: captures size = definition captures size.
	1 to: captures size do: [ :i | self assert: (captures at: i) type asCanonicalType = (definition captures at: i) requiredInitialValueType asCanonicalType].
	
	functionType := definition functionType.
	captureTypes := captures collect: [:each | each type].
	closureType := definition closureType.
	type := SLVMPointerType size: (definition compilationTarget pointerSize) baseType: closureType storage: definition addressSpace.

]

{ #category : #testing }
SLVMInstantiateClosure >> isInstantiateClosure [
	^ true
]

{ #category : #accessing }
SLVMInstantiateClosure >> type [
	^ type
]

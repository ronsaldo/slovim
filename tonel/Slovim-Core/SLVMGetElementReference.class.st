Class {
	#name : #SLVMGetElementReference,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMGetElementReference class >> reference: reference index: index [
	^ self new reference: reference index: index
]

{ #category : #visitor }
SLVMGetElementReference >> accept: aVisitor [
	^ aVisitor visitGetElementReference: self
]

{ #category : #accessing }
SLVMGetElementReference >> index [
	^ parameters second
]

{ #category : #printing }
SLVMGetElementReference >> mnemonic [
	^ 'getElementReference'
]

{ #category : #accessing }
SLVMGetElementReference >> reference [
	^ parameters first
]

{ #category : #construction }
SLVMGetElementReference >> reference: reference index: index [
	self parameters: { reference . index }.
	self assert: reference type isReferenceType.
	type := SLVMReferenceType baseType: (reference type baseType memberAt: index) storage: reference type storage
]

{ #category : #accessing }
SLVMGetElementReference >> type [
	^ type
]
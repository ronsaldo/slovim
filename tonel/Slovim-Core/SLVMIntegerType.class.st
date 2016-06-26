Class {
	#name : #SLVMIntegerType,
	#superclass : #SLVMPrimitiveType,
	#instVars : [
		'signed'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #'as yet unclassified' }
SLVMIntegerType class >> name: aName size: aSize alignment: anAlignment signed: aBoolean [
	^ (self name: aName size: aSize alignment: anAlignment) signed: aBoolean; yourself
]

{ #category : #comparing }
SLVMIntegerType >> = other [
	^ super = other and: [ signed = other isSigned ]
]

{ #category : #visitor }
SLVMIntegerType >> accept: aVisitor [
	^ aVisitor visitIntegerType: self
]

{ #category : #comparing }
SLVMIntegerType >> hash [
	^ super hash bitXor: signed hash
]

{ #category : #initialization }
SLVMIntegerType >> initialize [
	super initialize.
	signed := true.

]

{ #category : #testing }
SLVMIntegerType >> isIntegerType [
	^ true
]

{ #category : #testing }
SLVMIntegerType >> isSigned [
	^ signed
]

{ #category : #testing }
SLVMIntegerType >> isUnsigned [
	^ signed not
]

{ #category : #accessing }
SLVMIntegerType >> signed: anObject [
	signed := anObject
]
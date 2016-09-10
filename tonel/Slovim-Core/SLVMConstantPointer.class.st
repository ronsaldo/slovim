Class {
	#name : #SLVMConstantPointer,
	#superclass : #SLVMConstant,
	#instVars : [
		'type',
		'constant'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMConstantPointer class >> constant: constant pointerType: pointerType [
	^ self new constant: constant; type: pointerType; yourself
]

{ #category : #'as yet unclassified' }
SLVMConstantPointer >> = other [
	^ self class = other class and: [ self type = other type and: [ self constant = other constant ] ]
]

{ #category : #'as yet unclassified' }
SLVMConstantPointer >> accept: aVisitor [
	^ aVisitor visitConstantPointer: self
]

{ #category : #accessing }
SLVMConstantPointer >> constant [
	^ constant
]

{ #category : #accessing }
SLVMConstantPointer >> constant: anObject [
	constant := anObject
]

{ #category : #'as yet unclassified' }
SLVMConstantPointer >> hash [
	^ (self class hash bitXor: type hash) bitXor: constant hash
]

{ #category : #'as yet unclassified' }
SLVMConstantPointer >> isConstantPointer [
	^ true
]

{ #category : #accessing }
SLVMConstantPointer >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantPointer >> type: anObject [
	type := anObject
]

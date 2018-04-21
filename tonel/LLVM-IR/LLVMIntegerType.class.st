Class {
	#name : #LLVMIntegerType,
	#superclass : #LLVMType,
	#instVars : [
		'bits'
	],
	#category : #'LLVM-IR'
}

{ #category : #'as yet unclassified' }
LLVMIntegerType class >> get: context bits: bits [
	bits = 1 ifTrue: [ ^ self getInt1Ty: context ].
	bits = 8 ifTrue: [ ^ self getInt8Ty: context ].
	bits = 16 ifTrue: [ ^ self getInt16Ty: context ].
	bits = 32 ifTrue: [ ^ self getInt32Ty: context ].
	bits = 64 ifTrue: [ ^ self getInt64Ty: context ].
	bits = 128 ifTrue: [ ^ self getInt128Ty: context ].

	^ context typeAt: { self . bits } ifAbsentPut: [ self new bits: bits ]
]

{ #category : #accessing }
LLVMIntegerType >> bits [
	^ bits
]

{ #category : #accessing }
LLVMIntegerType >> bits: anObject [
	bits := anObject.
	name := ('i' , bits asString) asSymbol
]

{ #category : #testing }
LLVMIntegerType >> isIntegerTy [
	^ true
]

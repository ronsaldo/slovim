Class {
	#name : #LLVMIntegerType,
	#superclass : #LLVMType,
	#instVars : [
		'bits'
	],
	#category : #'LLVM-IR-Types'
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

{ #category : #'as yet unclassified' }
LLVMIntegerType >> allOnesConstant [
	^ LLVMConstantInt new
		type: self;
		value: (1 << bits) - 1;
		yourself
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

{ #category : #accessing }
LLVMIntegerType >> constant: aValue [
	self assert: aValue isInteger.
	^ LLVMConstantInt new
		type: self;
		value: aValue;
		yourself
]

{ #category : #testing }
LLVMIntegerType >> isIntegerTy [
	^ true
]

{ #category : #'as yet unclassified' }
LLVMIntegerType >> minusOneConstant [
	^ self constant: -1
]

{ #category : #'as yet unclassified' }
LLVMIntegerType >> oneConstant [
	^ self constant: 1
]

{ #category : #'as yet unclassified' }
LLVMIntegerType >> overloadedIntrinsicName [
	^ 'i', bits asString
]

{ #category : #'as yet unclassified' }
LLVMIntegerType >> zeroConstant [
	^ self constant: 0
]

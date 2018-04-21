Class {
	#name : #LLVMFloatingPointType,
	#superclass : #LLVMType,
	#instVars : [
		'bits'
	],
	#category : #'LLVM-IR'
}

{ #category : #accessing }
LLVMFloatingPointType >> bits [
	^ bits
]

{ #category : #accessing }
LLVMFloatingPointType >> bits: anObject [
	bits := anObject.
	name := ('i' , bits asString) asSymbol
]

{ #category : #testing }
LLVMFloatingPointType >> isDoubleTy [
	^ bits == 64
]

{ #category : #testing }
LLVMFloatingPointType >> isFloatTy [
	^ bits == 32
]

{ #category : #testing }
LLVMFloatingPointType >> isFloatingPointTy [
	^ true
]

{ #category : #testing }
LLVMFloatingPointType >> isHalfTy [
	^ bits == 16
]

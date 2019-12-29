Class {
	#name : #LLVMFloatingPointType,
	#superclass : #LLVMType,
	#instVars : [
		'bits'
	],
	#category : #'LLVM-IR-Types'
}

{ #category : #accessing }
LLVMFloatingPointType >> bits [
	^ bits
]

{ #category : #accessing }
LLVMFloatingPointType >> bits: anObject [
	bits := anObject
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

{ #category : #'as yet unclassified' }
LLVMFloatingPointType >> oneConstant [
	^ LLVMConstantFP new
		type: self;
		value: 1.0;
		yourself
]

{ #category : #'as yet unclassified' }
LLVMFloatingPointType >> overloadedIntrinsicName [
	^ 'f', bits asString
]

{ #category : #'as yet unclassified' }
LLVMFloatingPointType >> zeroConstant [
	^ LLVMConstantFP new
		type: self;
		value: 0.0;
		yourself
]

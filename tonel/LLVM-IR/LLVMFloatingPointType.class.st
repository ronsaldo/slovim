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

{ #category : #'as yet unclassified' }
LLVMFloatingPointType >> constantScalarValue: value [
	| sanitizedValue |
	sanitizedValue := value.
	bits = 32 ifTrue: [
		(value isInfinite or: [ value isNaN ]) ifFalse: [ 
			sanitizedValue := Float fromIEEE32Bit: sanitizedValue asIEEE32BitWord
		].
	].
	^ LLVMConstantFP new
		type: self;
		value: sanitizedValue;
		yourself
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
LLVMFloatingPointType >> minusOneConstant [
	^ self constantScalarValue: -1.0
]

{ #category : #'as yet unclassified' }
LLVMFloatingPointType >> oneConstant [
	^ self constantScalarValue: 1.0
]

{ #category : #'as yet unclassified' }
LLVMFloatingPointType >> overloadedIntrinsicName [
	^ 'f', bits asString
]

{ #category : #'as yet unclassified' }
LLVMFloatingPointType >> zeroConstant [
	^ self constantScalarValue: 0.0
]

Class {
	#name : #LLVMTypeTest,
	#superclass : #TestCase,
	#instVars : [
		'context'
	],
	#category : #'LLVM-IR-Tests'
}

{ #category : #tests }
LLVMTypeTest >> testTesting [
	context := LLVMContext new.
	self assert: context voidTy isVoidTy.
	self assert: context labelTy isLabelTy.
	self assert: context metadataTy isMetadataTy.
	
	self assert: context halfTy isFloatingPointTy.
	self assert: context halfTy isHalfTy.
	self assert: context floatTy isFloatingPointTy.
	self assert: context floatTy isFloatTy.
	self assert: context doubleTy isFloatingPointTy.
	self assert: context doubleTy isDoubleTy.
	
	self assert: context int1Ty isIntegerTy.
	self assert: context int8Ty isIntegerTy.
	self assert: context int16Ty isIntegerTy.
	self assert: context int32Ty isIntegerTy.
	self assert: context int64Ty isIntegerTy.
	self assert: context int128Ty isIntegerTy.
]

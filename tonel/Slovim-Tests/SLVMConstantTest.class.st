"
A DAIRConstantTest is a test class for testing the behavior of DAIRConstant
"
Class {
	#name : #SLVMConstantTest,
	#superclass : #TestCase,
	#category : #'Slovim-Tests'
}

{ #category : #'as yet unclassified' }
SLVMConstantTest >> testConstantBool [
	| constant |
	constant := SLVMConstant bool: true.
	self assert: constant type equals: SLVMType boolType. 
	self assert: constant value equals: true.
]

{ #category : #'as yet unclassified' }
SLVMConstantTest >> testConstantDouble [
	| constant |
	constant := SLVMConstant double: 1.0.
	self assert: constant type equals: SLVMType doubleType. 
	self assert: constant value equals: 1.0.
]

{ #category : #'as yet unclassified' }
SLVMConstantTest >> testConstantFloat [
	| constant |
	constant := SLVMConstant float: 1.0.
	self assert: constant type equals: SLVMType floatType. 
	self assert: constant value equals: 1.0.
]

{ #category : #'as yet unclassified' }
SLVMConstantTest >> testConstantInt [
	| constant |
	constant := SLVMConstant int: 1.
	self assert: constant type equals: SLVMType intType. 
	self assert: constant value equals: 1.
]

{ #category : #'as yet unclassified' }
SLVMConstantTest >> testConstantLong [
	| constant |
	constant := SLVMConstant long: 1.
	self assert: constant type equals: SLVMType longType. 
	self assert: constant value equals: 1.
]

{ #category : #'as yet unclassified' }
SLVMConstantTest >> testConstantUInt [
	| constant |
	constant := SLVMConstant uint: 1.
	self assert: constant type equals: SLVMType uintType. 
	self assert: constant value equals: 1.
]

{ #category : #'as yet unclassified' }
SLVMConstantTest >> testConstantULong [
	| constant |
	constant := SLVMConstant ulong: 1.
	self assert: constant type equals: SLVMType ulongType. 
	self assert: constant value equals: 1.
]

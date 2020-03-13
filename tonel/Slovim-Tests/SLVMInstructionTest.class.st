"
A DAIRInstructionTest is a test class for testing the behavior of DAIRInstruction
"
Class {
	#name : #SLVMInstructionTest,
	#superclass : #TestCase,
	#category : #'Slovim-Tests'
}

{ #category : #tests }
SLVMInstructionTest >> testBinaryOperation [
	| instruction left right |
	left := SLVMConstant int: 1.
	right := SLVMConstant int: 2.
	instruction := SLVMBinaryOperation operation: #add left: left right: right.
	self assert: instruction isTerminator not.
	self assert: instruction left = left.
	self assert: instruction right = right.
	self assert: instruction type isIntegerType.
	self assert: instruction asFullSExpression equals: 
		#(nil add i32 () ((const i32 1) (const i32 2))).
]

{ #category : #tests }
SLVMInstructionTest >> testReturn [
	| instruction value |
	value := SLVMConstant int: 1.
	instruction := SLVMReturn value: value.
	self assert: instruction isTerminator.
	self assert: instruction value = value.
	self assert: instruction type isVoidType.
	self assert: instruction asFullSExpression equals: 
		#(nil return void () ((const i32 1))).
]

{ #category : #tests }
SLVMInstructionTest >> testReturnVoid [
	| instruction |
	instruction := SLVMReturnVoid new.
	self assert: instruction isTerminator.
	self assert: instruction type isVoidType.
	self assert: instruction asFullSExpression equals: 
		#(nil returnVoid void () ()).
]

{ #category : #tests }
SLVMInstructionTest >> testUnreachable [
	| instruction |
	instruction := SLVMUnreacheable new.
	self assert: instruction isTerminator.
	self assert: instruction isUnreachable.
	self assert: instruction type isVoidType.
	self assert: instruction asFullSExpression equals: 
		#(nil unreachable void () ()).
]

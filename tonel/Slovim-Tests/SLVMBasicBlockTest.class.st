"
A DAIRBasicBlockTest is a test class for testing the behavior of DAIRBasicBlock
"
Class {
	#name : #SLVMBasicBlockTest,
	#superclass : #TestCase,
	#category : #'Slovim-Tests'
}

{ #category : #'as yet unclassified' }
SLVMBasicBlockTest >> testAddInstruction [
	| basicBlock instruction |
	basicBlock := SLVMBasicBlock new.
	instruction := SLVMInstruction new.
	basicBlock add: instruction.
	self deny: basicBlock isEmpty.
	self assert: basicBlock numberOfInstructions = 1.
	self assert: basicBlock firstInstruction == instruction.
	self assert: basicBlock predecessors isEmpty.
	self assert: basicBlock successors isEmpty.
	self assert: instruction block = basicBlock
	
]

{ #category : #'as yet unclassified' }
SLVMBasicBlockTest >> testNew [
	| basicBlock |
	basicBlock := SLVMBasicBlock new.
	self assert: basicBlock isEmpty.
	self assert: basicBlock numberOfInstructions = 0.
	self assert: basicBlock predecessors isEmpty.
	self assert: basicBlock successors isEmpty.
	
]

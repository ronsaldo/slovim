"
A DAIRBasicBlockTest is a test class for testing the behavior of DAIRBasicBlock
"
Class {
	#name : #SLVMBasicBlockTest,
	#superclass : #TestCase,
	#category : #'Slovim-Tests'
}

{ #category : #tests }
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

{ #category : #tests }
SLVMBasicBlockTest >> testNew [
	| basicBlock |
	basicBlock := SLVMBasicBlock new.
	self assert: basicBlock isEmpty.
	self assert: basicBlock numberOfInstructions = 0.
	self assert: basicBlock predecessors isEmpty.
	self assert: basicBlock successors isEmpty.
	
]

{ #category : #tests }
SLVMBasicBlockTest >> testStealStructuredCFGHeaderFrom [
	| header merge continue oldHeader |
	oldHeader := SLVMBasicBlock new.
	header := SLVMBasicBlock new.
	merge := SLVMBasicBlock new.
	continue := SLVMBasicBlock new.
	
	oldHeader
		mergeBlock: merge;
		continueBlock: continue.
		
	header stealStructuredCFGRoleFrom: oldHeader.

	self assert: oldHeader mergeBlock equals: nil.
	self assert: oldHeader continueBlock equals: nil.
	
	self assert: merge structuredControlFlowHeader equals: header.
	self assert: continue structuredControlFlowHeader equals: header.
	self deny: header isStructuredControlFlowMergeBlock.
	self deny: header isStructuredControlFlowContinueBlock.

	self assert: merge isStructuredControlFlowMergeBlock.
	self deny: merge isStructuredControlFlowContinueBlock.

	self deny: continue isStructuredControlFlowMergeBlock.
	self assert: continue isStructuredControlFlowContinueBlock.

]

{ #category : #tests }
SLVMBasicBlockTest >> testStructuredControlFlowLinks [
	| header merge continue |
	header := SLVMBasicBlock new.
	merge := SLVMBasicBlock new.
	continue := SLVMBasicBlock new.
	
	header
		mergeBlock: merge;
		continueBlock: continue.
		
	self assert: header isPartOfStructuredControlFlow.
	self assert: merge isPartOfStructuredControlFlow.
	self assert: continue isPartOfStructuredControlFlow.
	
	self assert: merge structuredControlFlowHeader equals: header.
	self assert: continue structuredControlFlowHeader equals: header.
	self deny: header isStructuredControlFlowMergeBlock.
	self deny: header isStructuredControlFlowContinueBlock.

	self assert: merge isStructuredControlFlowMergeBlock.
	self deny: merge isStructuredControlFlowContinueBlock.
	self assert: merge isStructuredControlFlowMergeOrContinueBlock.

	self deny: continue isStructuredControlFlowMergeBlock.
	self assert: continue isStructuredControlFlowContinueBlock.
	self assert: merge isStructuredControlFlowMergeOrContinueBlock.

]

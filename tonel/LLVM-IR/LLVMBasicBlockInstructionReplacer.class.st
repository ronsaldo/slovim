Class {
	#name : #LLVMBasicBlockInstructionReplacer,
	#superclass : #LLVMObject,
	#instVars : [
		'block',
		'newBasicBlocks',
		'perBlockInstructions'
	],
	#category : #'LLVM-IR'
}

{ #category : #adding }
LLVMBasicBlockInstructionReplacer >> add: anInstruction [
	perBlockInstructions last add: anInstruction.
	^ anInstruction
]

{ #category : #accessing }
LLVMBasicBlockInstructionReplacer >> block [
	^ block
]

{ #category : #accessing }
LLVMBasicBlockInstructionReplacer >> block: anObject [
	block := anObject
]

{ #category : #replacing }
LLVMBasicBlockInstructionReplacer >> insertAllocaInstruction: allocaInstruction [
	| firstBlockNewInstructions |
	firstBlockNewInstructions := perBlockInstructions first.
	firstBlockNewInstructions doWithIndex: [ :instruction :index |
		instruction isAlloca ifFalse: [
			firstBlockNewInstructions add: allocaInstruction beforeIndex: index .
			^ self
		].
	].

	firstBlockNewInstructions add: allocaInstruction
]

{ #category : #'instance creation' }
LLVMBasicBlockInstructionReplacer >> newBasicBlock [
	| newBasicBlock |
	newBasicBlock := LLVMBasicBlock new parent: block parent.
	newBasicBlocks add: newBasicBlock.
	perBlockInstructions add: OrderedCollection new.
	^ newBasicBlock
]

{ #category : #'as yet unclassified' }
LLVMBasicBlockInstructionReplacer >> newBasicBlocks [
	^ newBasicBlocks
]

{ #category : #replacing }
LLVMBasicBlockInstructionReplacer >> replaceWith: aBlock [
	newBasicBlocks := OrderedCollection new.
	newBasicBlocks add: block.
	perBlockInstructions := OrderedCollection new.
	perBlockInstructions add: OrderedCollection new.

	block instructions do: aBlock.
	
	perBlockInstructions doWithIndex: [ :newBlockInstructions :newBlockIndex |
		(newBasicBlocks at: newBlockIndex)
			instructions: newBlockInstructions
	].

]

{ #category : #adding }
LLVMBasicBlockInstructionReplacer >> setEndingBlock [
	newBasicBlocks size > 1 ifTrue: [
		block endingBlock: newBasicBlocks last
	]
]

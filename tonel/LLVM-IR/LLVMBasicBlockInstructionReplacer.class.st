Class {
	#name : #LLVMBasicBlockInstructionReplacer,
	#superclass : #LLVMObject,
	#instVars : [
		'block',
		'newInstructions'
	],
	#category : #'LLVM-IR'
}

{ #category : #adding }
LLVMBasicBlockInstructionReplacer >> add: anInstruction [
	newInstructions add: anInstruction.
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

{ #category : #accessing }
LLVMBasicBlockInstructionReplacer >> newInstructions [
	^ newInstructions
]

{ #category : #replacing }
LLVMBasicBlockInstructionReplacer >> replaceWith: aBlock [
	newInstructions := OrderedCollection new.
	block instructions do: aBlock.
	block instructions: newInstructions
]

Class {
	#name : #LLVMIRBuilder,
	#superclass : #LLVMObject,
	#instVars : [
		'context',
		'insertionPoint'
	],
	#category : #'LLVM-IR'
}

{ #category : #'as yet unclassified' }
LLVMIRBuilder class >> forBasicBlock: aBasicBlock [
	^ self new
		context: aBasicBlock context;
		insertionPoint: aBasicBlock;
		yourself
]

{ #category : #operators }
LLVMIRBuilder >> add: left with: right [
	^ self add: left with: right name: nil
]

{ #category : #operators }
LLVMIRBuilder >> add: left with: right name: name [
	^ self binaryOperation: #add left: left right: right name: name
]

{ #category : #adding }
LLVMIRBuilder >> addInstruction: anInstruction [
	insertionPoint addNext: anInstruction.
	^ anInstruction
]

{ #category : #operators }
LLVMIRBuilder >> binaryOperation: operation left: left right: right [
	^ self binaryOperation: operation left: left right: right name: nil
]

{ #category : #operators }
LLVMIRBuilder >> binaryOperation: operation left: left right: right name: name [
	^ self addInstruction: (LLVMBinaryOperator new
		name: name;
		type: left type;
		operation: operation;
		left: left;
		right: right;
		yourself)
]

{ #category : #instructions }
LLVMIRBuilder >> call: calledFunction arguments: arguments [
	^ self call: calledFunction arguments: arguments name: nil
]

{ #category : #instructions }
LLVMIRBuilder >> call: calledFunction arguments: arguments name: name [
	^ self addInstruction: (LLVMCallInst new
		name: name;
		type: calledFunction type elementType returnType;
		calledFunction: calledFunction;
		arguments: arguments;
		yourself)
]

{ #category : #accessing }
LLVMIRBuilder >> context [
	^ context
]

{ #category : #accessing }
LLVMIRBuilder >> context: anObject [
	context := anObject
]

{ #category : #operators }
LLVMIRBuilder >> fadd: left with: right [
	^ self fadd: left with: right name: nil
]

{ #category : #operators }
LLVMIRBuilder >> fadd: left with: right name: name [
	^ self binaryOperation: #fadd left: left right: right name: name
]

{ #category : #operators }
LLVMIRBuilder >> fdiv: left with: right [
	^ self fdiv: left with: right name: nil
]

{ #category : #operators }
LLVMIRBuilder >> fdiv: left with: right name: name [
	^ self binaryOperation: #fdiv left: left right: right name: name
]

{ #category : #operators }
LLVMIRBuilder >> fmul: left with: right [
	^ self fmul: left with: right name: nil
]

{ #category : #operators }
LLVMIRBuilder >> fmul: left with: right name: name [
	^ self binaryOperation: #fmul left: left right: right name: name
]

{ #category : #operators }
LLVMIRBuilder >> fsub: left with: right [
	^ self fsub: left with: right name: nil
]

{ #category : #operators }
LLVMIRBuilder >> fsub: left with: right name: name [
	^ self binaryOperation: #fsub left: left right: right name: name
]

{ #category : #accessing }
LLVMIRBuilder >> insertionPoint [
	^ insertionPoint
]

{ #category : #accessing }
LLVMIRBuilder >> insertionPoint: anObject [
	insertionPoint := anObject
]

{ #category : #operators }
LLVMIRBuilder >> mul: left with: right [
	^ self mul: left with: right name: nil
]

{ #category : #operators }
LLVMIRBuilder >> mul: left with: right name: name [
	^ self binaryOperation: #mul left: left right: right name: name
]

{ #category : #instructions }
LLVMIRBuilder >> return: returnedValue [
	^ self return: returnedValue name: nil
]

{ #category : #instructions }
LLVMIRBuilder >> return: returnedValue name: name [
	^ self addInstruction: (LLVMReturnInst new
		name: name;
		type: context voidTy;
		value: returnedValue;
		yourself)
]

{ #category : #instructions }
LLVMIRBuilder >> returnVoid [
	^ self return: nil
]

{ #category : #instructions }
LLVMIRBuilder >> returnVoid: name [
	^ self return: nil name: name
]

{ #category : #operators }
LLVMIRBuilder >> sdiv: left with: right [
	^ self sdiv: left with: right name: nil
]

{ #category : #operators }
LLVMIRBuilder >> sdiv: left with: right name: name [
	^ self binaryOperation: #sdiv left: left right: right name: name
]

{ #category : #operators }
LLVMIRBuilder >> sub: left with: right [
	^ self sub: left with: right name: nil
]

{ #category : #operators }
LLVMIRBuilder >> udiv: left with: right [
	^ self udiv: left with: right name: nil
]

{ #category : #operators }
LLVMIRBuilder >> udiv: left with: right name: name [
	^ self binaryOperation: #udiv left: left right: right name: name
]

{ #category : #instructions }
LLVMIRBuilder >> unreachable [
	^ self unreachable: nil
]

{ #category : #instructions }
LLVMIRBuilder >> unreachable: name [
	^ self addInstruction: (LLVMUnreachableInst new
		name: name;
		type: context voidTy;
		yourself)
]

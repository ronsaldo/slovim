Class {
	#name : #SLVMUnaryOperation,
	#superclass : #SLVMInstruction,
	#instVars : [
		'operation',
		'type'
	],
	#classVars : [
		'OperationSignatures'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'class initialization' }
SLVMUnaryOperation class >> initialize [
	"
	self initialize.
	"
	super initialize.
	
	OperationSignatures := Dictionary newFromPairs: #(
		neg		integer
		not   integer
		lnot  bool 
		fneg   float
	).

]

{ #category : #construction }
SLVMUnaryOperation class >> operation: operation operand: operand [
	^ self new operation: operation operand: operand
]

{ #category : #visitor }
SLVMUnaryOperation >> accept: aVisitor [
	^ aVisitor visitUnaryOperation: self
]

{ #category : #'as yet unclassified' }
SLVMUnaryOperation >> computeTypeFor: anOperation operand: operand [
	| operandType rightType operationType |
	operandType := operand type.
	operationType := OperationSignatures at: anOperation.
	
	operationType == #integer ifTrue: [ 
		(operandType isIntegerType or: [operandType isVectorType and: [operandType baseType isIntegerType ] ]) ifFalse: [ self error: 'Unary operation ' , anOperation , ' requires integer operand.' ].
		^ operandType
	].

	operationType == #float ifTrue: [ 
		(operandType isFloatType or: [operandType isVectorType and: [operandType baseType isFloatType ] ]) ifFalse: [ self error: 'Unary operation ' , anOperation , ' requires float operands.' ].
		^ operandType
	].

	self error: 'Unsupported operation type'

]

{ #category : #printing }
SLVMUnaryOperation >> mnemonic [
	^ self operation
]

{ #category : #accessing }
SLVMUnaryOperation >> operand [
	^ parameters first
]

{ #category : #accessing }
SLVMUnaryOperation >> operation [
	^ operation
]

{ #category : #construction }
SLVMUnaryOperation >> operation: anOperation operand: operand [
	operation := anOperation.
	type := self computeTypeFor: anOperation operand: operand.
	self parameters: { operand }
]

{ #category : #accessing }
SLVMUnaryOperation >> type [
	^ type
]

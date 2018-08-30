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
		neg		(integer evaluateNegated)
		not   (integer evaluateBitNot)
		lnot  (bool evaluateLogicalNot)

		fneg   (float evaluateNegated)
		fsqrt  (float evaluateSqrt)
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
	| operandType operationType |
	operandType := operand type.
	operationType := (OperationSignatures at: anOperation) first.
	
	operationType == #integer ifTrue: [ 
		(operandType isIntegerType or: [operandType isVectorType and: [operandType baseType isIntegerType ] ]) ifFalse: [ self error: 'Unary operation ' , anOperation , ' requires integer operand.' ].
		^ operandType
	].

	operationType == #float ifTrue: [ 
		(operandType isFloatType or: [operandType isVectorType and: [operandType baseType isFloatType ] ]) ifFalse: [ self error: 'Unary operation ' , anOperation , ' requires float operands.' ].
		^ operandType
	].
	operationType == #bool ifTrue: [ 
		(operandType isBooleanType or: [operandType isVectorType and: [operandType baseType isBooleanType ] ]) ifFalse: [ self error: 'Unary operation ' , anOperation , ' requires float operands.' ].
		^ operandType
	].
	self error: 'Unsupported operation type'

]

{ #category : #'constant folding' }
SLVMUnaryOperation >> evaluateBitNot [
	^ SLVMConstant type: type value: (self operand value bitInvert)
]

{ #category : #'constant folding' }
SLVMUnaryOperation >> evaluateLogicalNot [
	^ SLVMConstant type: type value: (self operand value not)
]

{ #category : #'constant folding' }
SLVMUnaryOperation >> evaluateNegated [
	^ SLVMConstant type: type value: (self operand value negated)
]

{ #category : #'constant folding' }
SLVMUnaryOperation >> evaluateSqrt [
	^ SLVMConstant type: type value: (self operand value sqrt)
]

{ #category : #'basic optimizations' }
SLVMUnaryOperation >> foldConstant [
	(self operand isConstant) ifTrue: [ 
		^ self perform: (OperationSignatures at: operation) second.
	].
	^ self
]

{ #category : #testing }
SLVMUnaryOperation >> isLogicalNot [
	^ operation == #lnot
]

{ #category : #testing }
SLVMUnaryOperation >> isPureInstruction [
	^ true
]

{ #category : #testing }
SLVMUnaryOperation >> isUnaryOperation [
	^ true
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
SLVMUnaryOperation >> signature [
	^ super signature , { operation }
]

{ #category : #accessing }
SLVMUnaryOperation >> type [
	^ type
]

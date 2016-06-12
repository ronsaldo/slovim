Class {
	#name : #SLVMBinaryOperation,
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
SLVMBinaryOperation class >> initialize [
	"
	self initialize.
	"
	super initialize.
	
	OperationSignatures := Dictionary newFromPairs: #(
		add		integer
		sub   integer 
		mul   integer
		div   integer
		udiv  integer
		rem   integer
		urem  integer

		bitand integer
		bitor integer
		bitxor integer

		shiftleft integer
		shiftright integer

		ilt integerComp
		ile integerComp
		ieq integerComp
		ine integerComp
		igt integerComp
		ige integerComp

		fadd 		float
		fsub 		float
		fmul 		float
		fdiv 		float
		frem 		float

		uflt floatComp
		ufle floatComp
		ufeq floatComp
		ufne floatComp
		ufgt floatComp
		ufge floatComp

		oflt floatComp
		ofle floatComp
		ofeq floatComp
		ofne floatComp
		ofgt floatComp
		ofge floatComp
		
		mulMatrixMatrix matrixMatrix
		mulMatrixVector matrixVector
		mulVectorMatrix vectorMatrix
	).

]

{ #category : #construction }
SLVMBinaryOperation class >> operation: operation left: leftOperand right: rightOperand [
	^ self new operation: operation left: leftOperand right: rightOperand

]

{ #category : #visitor }
SLVMBinaryOperation >> accept: aVisitor [
	^ aVisitor visitBinaryOperation: self
]

{ #category : #accessing }
SLVMBinaryOperation >> computeTypeFor: anOperation left: leftOperand right: rightOperand [
	| leftType rightType operationType |
	leftType := leftOperand type.
	rightType := rightOperand type.
	operationType := OperationSignatures at: anOperation.
	operationType == #matrixMatrix ifTrue: [ 
		self assert: leftType isMatrixType.
		self assert: rightType isMatrixType.
		self assert: leftType baseType = rightType baseType.
		self assert: leftType columns = rightType rows.
		^ SLVMMatrixType baseType: leftType baseType rows: leftType rows columns: rightType columns alignment: leftType alignment
	].

	operationType == #matrixVector ifTrue: [ 
		self assert: leftType isMatrixType.
		self assert: rightType isVectorType.
		self assert: leftType baseType = rightType baseType.
		self assert: leftType columns = rightType elements.
		^ rightType
	].

	operationType == #vectorMatrix ifTrue: [ 
		self assert: leftType isVectorType.
		self assert: rightType isMatrixType.
		self assert: leftType baseType = rightType baseType.
		self assert: leftType elements = rightType rows.
		^ leftType
	].

	leftType ~= rightType ifTrue: [ self error: 'Unsupported binary operation whose operands have a different type.' ].
	
	((operationType == #integer) or: [ operationType == #integerComp ]) ifTrue: [ 
		(leftType isIntegerType or: [leftType isVectorType and: [leftType baseType isIntegerType ] ]) ifFalse: [ self error: 'Binary operation ' , anOperation , ' requires integer operands.' ].
		^ operationType == #integerComp ifTrue: [ SLVMType boolType ] ifFalse: [ leftType ]
	].

	((operationType == #float) or: [ operationType == #floatComp ]) ifTrue: [ 
		(leftType isFloatType or: [leftType isVectorType and: [leftType baseType isFloatType ] ]) ifFalse: [ self error: 'Binary operation ' , anOperation , ' requires floating point operands.' ].
		^ operationType == #floatComp ifTrue: [ SLVMType boolType ] ifFalse: [ leftType ]
	].

	self error: 'Unsupported operation type'

]

{ #category : #accessing }
SLVMBinaryOperation >> left [
	^ parameters first
]

{ #category : #printing }
SLVMBinaryOperation >> mnemonic [
	^ self operation
]

{ #category : #accessing }
SLVMBinaryOperation >> operation [
	^ operation
]

{ #category : #construction }
SLVMBinaryOperation >> operation: anOperation left: leftOperand right: rightOperand [
	operation := anOperation.
	type := self computeTypeFor: anOperation left: leftOperand right: rightOperand.
	self parameters: { leftOperand . rightOperand }
]

{ #category : #accessing }
SLVMBinaryOperation >> right [
	^ parameters second
]

{ #category : #accessing }
SLVMBinaryOperation >> type [
	^ type
]

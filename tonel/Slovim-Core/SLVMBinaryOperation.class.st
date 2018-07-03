"
I represent a binary operation
"
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
		add		(integer evaluateAdd)
		sub   (integer evaluateSub) 
		mul   (integer evaluateMul)
		div   (integer evaluateIDiv)
		udiv  (integer evaluateIDiv)
		rem   (integer evaluateIRem)
		urem  (integer evaluateIRem)

		bitand (integer evaluateBitAnd)
		bitor (integer evaluateBitOr)
		bitxor (integer evaluateBitXOr)

		shiftleft (integer evaluateShiftLeft)
		shiftright (integer evaluateArithmeticShiftRight)
		shiftrightarithmetic (integer evaluateLogicalShiftRight)
		rotateleft (integer evaluateRotateLeft)
		rotateright (integer evaluateRotateRight)

		ilt (integerComp evaluateLessThan)
		ile (integerComp evaluateLessEqual)
		ieq (integerComp evaluateEqual)
		ine (integerComp evaluateNotEqual)
		igt (integerComp evaluateGreaterThan)
		ige (integerComp evaluateGreaterEqual)

		ult (integerComp evaluateLessThan)
		ule (integerComp evaluateLessEqual)
		ugt (integerComp evaluateGreaterThan)
		uge (integerComp evaluateGreaterEqual)

		fadd 		(float evaluateAdd)
		fsub 		(float evaluateSub)
		fmul 		(float evaluateMul)
		fdiv 		(float evaluateDiv)
		frem 		(float evaluateRem)

		uflt (floatComp evaluateLessThan)
		ufle (floatComp evaluateLessEqual)
		ufeq (floatComp evaluateEqual)
		ufne (floatComp evaluateNotEqual)
		ufgt (floatComp evaluateGreaterThan)
		ufge (floatComp evaluateGreaterEqual)

		oflt (floatComp evaluateLessThan)
		ofle (floatComp evaluateLessEqual)
		ofeq (floatComp evaluateEqual)
		ofne (floatComp evaluateNotEqual)
		ofgt (floatComp evaluateGreaterThan)
		ofge (floatComp evaluateGreaterEqual)
		
		dynObjectIdentityEquals (dynObjectComp evaluateIdentityEquals)
		dynObjectIdentityNotEquals (dynObjectComp evaluateIdentityNotEquals)
		
		mulMatrixMatrix (matrixMatrix evaluateMulMatrixMatrix)
		mulMatrixVector (matrixVector evaluateMulMatrixVector)
		mulVectorMatrix (vectorMatrix evaluateMulVectorMatrix)
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
	operationType := (OperationSignatures at: anOperation) first.
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
		(leftType isIntegerType or: [leftType isIntegerVectorType or: [leftType isIntegerMatrixType ] ]) ifFalse: [
			(operationType == #integerComp and: [ leftType isPointerType ]) ifFalse: [ 
				self error: 'Binary operation ' , anOperation , ' requires integer operands.'
			]
		].
		^ operationType == #integerComp ifTrue: [ SLVMType boolType ] ifFalse: [ leftType ]
	].

	((operationType == #float) or: [ operationType == #floatComp ]) ifTrue: [ 
		(leftType isFloatType or: [leftType isFloatVectorType or: [leftType isFloatMatrixType ] ]) ifFalse: [ self error: 'Binary operation ' , anOperation , ' requires floating point operands.' ].
		^ operationType == #floatComp ifTrue: [ SLVMType boolType ] ifFalse: [ leftType ]
	].

	((operationType == #dynObject) or: [ operationType == #dynObjectComp ]) ifTrue: [ 
		^ operationType == #dynObjectComp ifTrue: [ SLVMType boolType ] ifFalse: [ leftType ]
	].

	self error: 'Unsupported operation type'

]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateAdd [
	^ SLVMConstant type: type value: (self left value + self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateArithmeticShiftRight [
	^ SLVMConstant type: type value: (self left value bitShift: self right value negated)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateBitAnd [
	^ SLVMConstant type: type value: (self left value bitAnd: self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateBitOr [
	^ SLVMConstant type: type value: (self left value bitOr: self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateBitXOr [
	^ SLVMConstant type: type value: (self left value bitXor: self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateDiv [
	^ SLVMConstant type: type value: (self left value / self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateEqual [
	^ SLVMConstant type: type value: (self left value = self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateGreaterEqual [
	^ SLVMConstant type: type value: (self left value >= self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateGreaterThan [
	^ SLVMConstant type: type value: (self left value > self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateIDiv [
	^ SLVMConstant type: type value: (self left value // self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateIRem [
	^ SLVMConstant type: type value: (self left value \\ self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateLessEqual [
	^ SLVMConstant type: type value: (self left value <= self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateLessThan [
	^ SLVMConstant type: type value: (self left value < self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateLogicalShiftRight [
	^ SLVMConstant type: type value: (self left value bitShift: self right value negated)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateMul [
	^ SLVMConstant type: type value: (self left value * self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateNotEqual [
	^ SLVMConstant type: type value: (self left value ~= self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateRem [
	self flag: 'Implement this properly'.
	^ SLVMConstant type: type value: (self left value % self right value negated)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateShiftLeft [
	^ SLVMConstant type: type value: (self left value bitShift: self right value)
]

{ #category : #'constant folding' }
SLVMBinaryOperation >> evaluateSub [
	^ SLVMConstant type: type value: (self left value - self right value)
]

{ #category : #'basic optimizations' }
SLVMBinaryOperation >> foldConstant [
	(self left isConstant and: [ self right isConstant ]) ifTrue: [ 
		^ self perform: (OperationSignatures at: operation) second.
	].
	^ self
]

{ #category : #'as yet unclassified' }
SLVMBinaryOperation >> isBinaryComparison [
	| operationType |
	operationType := self operationType.
	^ #(integerComp floatComp dynObjectComp) includes: operationType
]

{ #category : #testing }
SLVMBinaryOperation >> isMatrixOperation [
	^ type isMatrixType or: [ self left type isMatrixType or: [self right type isMatrixType] ]
]

{ #category : #'as yet unclassified' }
SLVMBinaryOperation >> isPureInstruction [
	^ true
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
SLVMBinaryOperation >> operationType [
	^ (OperationSignatures at: operation) first
]

{ #category : #accessing }
SLVMBinaryOperation >> right [
	^ parameters second
]

{ #category : #accessing }
SLVMBinaryOperation >> type [
	^ type
]

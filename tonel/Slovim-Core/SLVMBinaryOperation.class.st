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
		add		(integer evaluateAdd optimizeAdd)
		sub   (integer evaluateSub optimizeSub) 
		mul   (integer evaluateMul optimizeMul)
		div   (integer evaluateIDiv optimizeDiv)
		udiv  (integer evaluateIDiv optimizeDiv)
		rem   (integer evaluateIRem optimizeRem)
		urem  (integer evaluateIRem optimizeRem)

		bitand (integer evaluateBitAnd noOptimization)
		bitor (integer evaluateBitOr noOptimization)
		bitxor (integer evaluateBitXOr noOptimization)

		shiftleft (integer evaluateShiftLeft noOptimization)
		shiftright (integer evaluateArithmeticShiftRight noOptimization)
		shiftrightarithmetic (integer evaluateLogicalShiftRight noOptimization)
		rotateleft (integer evaluateRotateLeft noOptimization)
		rotateright (integer evaluateRotateRight noOptimization)

		ilt (integerComp evaluateLessThan noOptimization)
		ile (integerComp evaluateLessEqual noOptimization)
		ieq (integerComp evaluateEqual noOptimization)
		ine (integerComp evaluateNotEqual noOptimization)
		igt (integerComp evaluateGreaterThan noOptimization)
		ige (integerComp evaluateGreaterEqual noOptimization)

		ult (integerComp evaluateLessThan noOptimization)
		ule (integerComp evaluateLessEqual noOptimization)
		ugt (integerComp evaluateGreaterThan noOptimization)
		uge (integerComp evaluateGreaterEqual noOptimization)

		fadd 		(float evaluateAdd optimizeFloatAdd)
		fsub 		(float evaluateSub optimizeFloatSub)
		fmul 		(float evaluateMul optimizeFloatMul)
		fdiv 		(float evaluateDiv optimizeFloatDiv)
		frem 		(float evaluateRem optimizeFloatRem)

		uflt (floatComp evaluateLessThan noOptimization)
		ufle (floatComp evaluateLessEqual noOptimization)
		ufeq (floatComp evaluateEqual noOptimization)
		ufne (floatComp evaluateNotEqual noOptimization)
		ufgt (floatComp evaluateGreaterThan noOptimization)
		ufge (floatComp evaluateGreaterEqual noOptimization)

		oflt (floatComp evaluateLessThan noOptimization)
		ofle (floatComp evaluateLessEqual noOptimization)
		ofeq (floatComp evaluateEqual noOptimization)
		ofne (floatComp evaluateNotEqual noOptimization)
		ofgt (floatComp evaluateGreaterThan noOptimization)
		ofge (floatComp evaluateGreaterEqual noOptimization)
		
		dynObjectIdentityEquals (dynObjectComp evaluateIdentityEquals noOptimization)
		dynObjectIdentityNotEquals (dynObjectComp evaluateIdentityNotEquals noOptimization)
		
		mulMatrixMatrix (matrixMatrix evaluateMulMatrixMatrix noOptimization)
		mulMatrixVector (matrixVector evaluateMulMatrixVector noOptimization)
		mulVectorMatrix (vectorMatrix evaluateMulVectorMatrix noOptimization)
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
		(leftType isIntegerType or: [leftType isIntegerVectorType or: [leftType isIntegerMatrixType or: [leftType isBooleanType ] ] ]) ifFalse: [
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
SLVMBinaryOperation >> foldArithmeticIdentities [
	^ self perform: (OperationSignatures at: operation) third
]

{ #category : #'basic optimizations' }
SLVMBinaryOperation >> foldConstant [
	(self left isConstant and: [ self right isConstant ]) ifTrue: [ 
		^ self perform: (OperationSignatures at: operation) second.
	].
	
	^ self foldArithmeticIdentities
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

{ #category : #'arithmetic optimizations' }
SLVMBinaryOperation >> noOptimization [
	^ self
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

{ #category : #'arithmetic optimizations' }
SLVMBinaryOperation >> optimizeAdd [
	^ self
]

{ #category : #'arithmetic optimizations' }
SLVMBinaryOperation >> optimizeDiv [
	^ self
]

{ #category : #'arithmetic optimizations' }
SLVMBinaryOperation >> optimizeFloatAdd [
	| left right |
	left := self left.
	right := self right.
	
	left isZeroConstant ifTrue: [ ^ right ].
	right isZeroConstant ifTrue: [ ^ left ].
 
	^ self
]

{ #category : #'arithmetic optimizations' }
SLVMBinaryOperation >> optimizeFloatDiv [
	^ self
]

{ #category : #'arithmetic optimizations' }
SLVMBinaryOperation >> optimizeFloatMul [
	| left right |
	left := self left.
	right := self right.
	
	left isZeroConstant ifTrue: [ ^ left ].
	right isZeroConstant ifTrue: [ ^ right ].

	left isOneConstant ifTrue: [ ^ right ].
	right isOneConstant ifTrue: [ ^ left ].
 
	^ self
]

{ #category : #'arithmetic optimizations' }
SLVMBinaryOperation >> optimizeFloatRem [
	^ self
]

{ #category : #'arithmetic optimizations' }
SLVMBinaryOperation >> optimizeFloatSub [
	^ self
]

{ #category : #'arithmetic optimizations' }
SLVMBinaryOperation >> optimizeMul [
	^ self
]

{ #category : #'arithmetic optimizations' }
SLVMBinaryOperation >> optimizeRem [
	^ self
]

{ #category : #'arithmetic optimizations' }
SLVMBinaryOperation >> optimizeSub [
	^ self
]

{ #category : #accessing }
SLVMBinaryOperation >> right [
	^ parameters second
]

{ #category : #accessing }
SLVMBinaryOperation >> signature [
	^ super signature , { operation }
]

{ #category : #accessing }
SLVMBinaryOperation >> type [
	^ type
]

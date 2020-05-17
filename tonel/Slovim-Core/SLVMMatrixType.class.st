Class {
	#name : #SLVMMatrixType,
	#superclass : #SLVMType,
	#instVars : [
		'name',
		'baseType',
		'rows',
		'columns',
		'size',
		'alignment',
		'fullSExpression'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #construction }
SLVMMatrixType class >> baseType: aBaseType rows: numRows columns: numColumns [
	| alignmentMultiplier |
	alignmentMultiplier := numRows ~= 3 ifTrue: [ numRows ] ifFalse: [ 4 ].
	^ self baseType: aBaseType rows: numRows columns: numColumns alignment: aBaseType alignment * alignmentMultiplier
]

{ #category : #construction }
SLVMMatrixType class >> baseType: aBaseType rows: numRows columns: numColumns alignment: anAlignment [
	^ self new
		baseType: aBaseType;
		rows: numRows;
		columns: numColumns;
		alignment: anAlignment;
		size: (aBaseType size * numRows alignedTo: anAlignment) * numColumns;
		yourself
]

{ #category : #printing }
SLVMMatrixType class >> mnemonic [
	^ #matrix
]

{ #category : #comparing }
SLVMMatrixType >> = other [
	^ self class == other class
		and: [
			baseType = other baseType and:
			[ rows = other rows and:
			[ columns = other columns and:
			[ alignment = other alignment ] ] ] ]
]

{ #category : #visitor }
SLVMMatrixType >> accept: aVisitor [
	^ aVisitor visitMatrixType: self
]

{ #category : #accessing }
SLVMMatrixType >> alignment [
	^ alignment
]

{ #category : #accessing }
SLVMMatrixType >> alignment: anObject [
	alignment := anObject
]

{ #category : #converting }
SLVMMatrixType >> asFullSExpression [
	^ fullSExpression ifNil: [ fullSExpression := { self mnemonic . baseType asSExpression . rows . columns } ]
]

{ #category : #accessing }
SLVMMatrixType >> baseType [
	^ baseType
]

{ #category : #accessing }
SLVMMatrixType >> baseType: anObject [
	baseType := anObject
]

{ #category : #accessing }
SLVMMatrixType >> columnType [
	^ SLVMVectorType baseType: baseType elements: rows
]

{ #category : #accessing }
SLVMMatrixType >> columns [
	^ columns
]

{ #category : #accessing }
SLVMMatrixType >> columns: anObject [
	columns := anObject
]

{ #category : #'as yet unclassified' }
SLVMMatrixType >> decodeFromFullSExpression: encodedType context: decodingContext [
	self assert: encodedType size = 4.
	baseType := decodingContext decodeSExpressionType: encodedType second.
	rows := encodedType third.
	columns := encodedType third.
	alignment := baseType alignment * (rows ~= 3 ifTrue: [ rows ] ifFalse: [ 4 ]).
	size := (baseType size * rows alignedTo: alignment) * columns.

]

{ #category : #'as yet unclassified' }
SLVMMatrixType >> defaultFullConstant [
	^ SLVMConstant matrix: self columns: ((1 to: columns) collect: [:each | self columnType defaultFullConstant])
]

{ #category : #comparing }
SLVMMatrixType >> internalHash [
	^ (((self class hash bitXor: baseType hash) bitXor: rows hash) bitXor: columns hash) bitXor: alignment hash
]

{ #category : #testing }
SLVMMatrixType >> isBooleanMatrixType [
	^ baseType isBooleanType
]

{ #category : #testing }
SLVMMatrixType >> isColumnMajor [
	^ true
]

{ #category : #testing }
SLVMMatrixType >> isFloatMatrixType [
	^ baseType isFloatType
]

{ #category : #testing }
SLVMMatrixType >> isIntegerMatrixType [
	^ baseType isIntegerType
]

{ #category : #testing }
SLVMMatrixType >> isMatrixType [
	^ true
]

{ #category : #testing }
SLVMMatrixType >> isMemberInBoundsAt: index [
	^ index isConstantValue and: [ index value < columns ]
]

{ #category : #testing }
SLVMMatrixType >> isRowMajor [
	^ false
]

{ #category : #testing }
SLVMMatrixType >> isScalarType [
	^ false
]

{ #category : #accessing }
SLVMMatrixType >> memberAt: constantValue [
	^ self columnType
]

{ #category : #accessing }
SLVMMatrixType >> name [
	^ self printString asSymbol
]

{ #category : #printing }
SLVMMatrixType >> printOn: aStream [
	aStream print: baseType; print: rows; nextPut: $x; print: columns
]

{ #category : #accessing }
SLVMMatrixType >> rowType [
	^ SLVMVectorType baseType: baseType elements: columns
]

{ #category : #accessing }
SLVMMatrixType >> rows [
	^ rows
]

{ #category : #accessing }
SLVMMatrixType >> rows: anObject [
	rows := anObject
]

{ #category : #accessing }
SLVMMatrixType >> size [
	^ size
]

{ #category : #accessing }
SLVMMatrixType >> size: anObject [
	size := anObject
]

{ #category : #'as yet unclassified' }
SLVMMatrixType >> transposed [
	rows = columns ifTrue: [ ^ self ].
	^ self class baseType: baseType rows: columns columns: rows
]

{ #category : #accessing }
SLVMMatrixType >> typeOfMemberAt: index [
	^ self memberAt: index
]

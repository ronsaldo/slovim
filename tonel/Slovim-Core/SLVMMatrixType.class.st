Class {
	#name : #SLVMMatrixType,
	#superclass : #SLVMType,
	#instVars : [
		'name',
		'baseType',
		'rows',
		'columns',
		'size',
		'alignment'
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
		size: (aBaseType size * numColumns alignedTo: anAlignment) * numRows;
		yourself
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

{ #category : #comparing }
SLVMMatrixType >> hash [
	^ (((self class hash bitXor: baseType hash) bitXor: rows hash) bitXor: columns hash) bitXor: alignment hash
]

{ #category : #testing }
SLVMMatrixType >> isMatrixType [
	^ true
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

{ #category : #accessing }
SLVMMatrixType >> typeOfMemberAt: index [
	^ self memberAt: index
]

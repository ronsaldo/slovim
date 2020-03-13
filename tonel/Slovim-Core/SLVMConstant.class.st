"
I represent a constant whose value could be dependent on the target architecture or target module.
"
Class {
	#name : #SLVMConstant,
	#superclass : #SLVMValue,
	#category : #'Slovim-Core-SSA'
}

{ #category : #constructor }
SLVMConstant class >> add: left with: right [
	^ SLVMConstantExpresionAdd left: left right: right
]

{ #category : #constructor }
SLVMConstant class >> array: anArrayType blob: data [
	self assert: anArrayType isArrayType.
	^ SLVMConstantArrayBlob new type: anArrayType; data: data
]

{ #category : #constructor }
SLVMConstant class >> array: anArrayType slots: anArrayOfSlots [
	self assert: anArrayType isArrayType.
	^ SLVMConstantArrayValue new type: anArrayType; slots: anArrayOfSlots
]

{ #category : #constructor }
SLVMConstant class >> bool: aBoolean [
	^ self type: SLVMType boolType value: aBoolean
]

{ #category : #constructor }
SLVMConstant class >> cstring: value [
	^ SLVMStringConstantValue new
		type: (SLVMArrayType baseType: SLVMType charType elements: value size);
		hasExtraNullCharacter: true;
		data: value
]

{ #category : #constructor }
SLVMConstant class >> cstringPointer: aValue for: compilationTarget [
	^ self pointerToConstant: (SLVMConstant cstring: aValue) pointerType: (compilationTarget pointerTo: SLVMType charType)
]

{ #category : #constructor }
SLVMConstant class >> doubleAlign4: anInteger [
	^ self type: SLVMType doubleAlign4Type value: anInteger
]

{ #category : #constructor }
SLVMConstant class >> doubleAlign8: anInteger [
	^ self type: SLVMType doubleAlign8Type value: anInteger
]

{ #category : #constructor }
SLVMConstant class >> float: anInteger [
	^ self type: SLVMType floatType value: anInteger
]

{ #category : #constructor }
SLVMConstant class >> getPointer: constantPointer element: indices [
	^ SLVMConstantExpresionGetElementPointer pointer: constantPointer indices: indices
]

{ #category : #constructor }
SLVMConstant class >> getReference: reference element: elementIndex [
	^ self getPointer: reference element: { self int: 0. self int: elementIndex }
]

{ #category : #constructor }
SLVMConstant class >> int: anInteger [
	^ self type: SLVMType intType value: anInteger
]

{ #category : #constructor }
SLVMConstant class >> long: anInteger [
	^ self type: SLVMType longType value: anInteger
]

{ #category : #constructor }
SLVMConstant class >> matrix: aMatrixType columns: columns [
	self assert: aMatrixType isMatrixType.
	^ SLVMConstantMatrixValue new type: aMatrixType; slots: columns
]

{ #category : #constructor }
SLVMConstant class >> nullPointer: pointerType [
	^ self type: pointerType value: 0
]

{ #category : #constructor }
SLVMConstant class >> pointer: value castTo: aTargetType [
	^ self value: value bitcast: aTargetType
]

{ #category : #constructor }
SLVMConstant class >> pointerToConstant: constant pointerType: pointerType [
	^ SLVMConstantPointer constant: constant pointerType: pointerType
]

{ #category : #constructor }
SLVMConstant class >> structure: aStructureType slots: anArrayOfSlots [
	self assert: aStructureType isStructureType.
	^ SLVMConstantStructureValue new type: aStructureType; slots: anArrayOfSlots
]

{ #category : #constructor }
SLVMConstant class >> type: aSLVMType value: aConstantValue [
	aSLVMType isIntegerType ifTrue: [ self assert: aConstantValue isInteger ].
	^ SLVMConstantValue new type: aSLVMType; value: aConstantValue
]

{ #category : #constructor }
SLVMConstant class >> uchar: anInteger [
	^ self type: SLVMType ucharType value: anInteger
]

{ #category : #constructor }
SLVMConstant class >> uint: anInteger [
	^ self type: SLVMType uintType value: anInteger
]

{ #category : #constructor }
SLVMConstant class >> ulong: anInteger [
	^ self type: SLVMType ulongType value: anInteger
]

{ #category : #constructor }
SLVMConstant class >> undefined: type [
	^ SLVMConstantUndefined new type: type
]

{ #category : #constructor }
SLVMConstant class >> union: anUnionType blob: encodedBlobData [
	self assert: anUnionType isUnionType.
	^ SLVMConstantUnionBlobValue new type: anUnionType; data: encodedBlobData
]

{ #category : #constructor }
SLVMConstant class >> value: value bitcast: aTargetType [
	value type = aTargetType ifTrue: [ ^ value ].
	value isConstantExpressionBitCast ifTrue: [
		^ SLVMConstantExpresionBitCast new value: value value targetType: aTargetType
	].
	^ SLVMConstantExpresionBitCast new value: value targetType: aTargetType
]

{ #category : #constructor }
SLVMConstant class >> vector: aVectorType elements: vectorElements [
	self assert: aVectorType isVectorType.
	^ SLVMConstantVectorValue new type: aVectorType; slots: vectorElements
]

{ #category : #constructor }
SLVMConstant class >> zeroInitializer: type [
	^ SLVMConstantZeroInitializer new type: type
	
]

{ #category : #testing }
SLVMConstant >> isCompiledMethodMetaData [
	^ false
]

{ #category : #testing }
SLVMConstant >> isConstant [
	^ true
]

{ #category : #testing }
SLVMConstant >> isFunctionDynamicLiteral [
	^ false
]

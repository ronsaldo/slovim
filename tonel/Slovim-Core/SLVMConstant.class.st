Class {
	#name : #SLVMConstant,
	#superclass : #SLVMValue,
	#category : #'Slovim-Core-SSA'
}

{ #category : #constructor }
SLVMConstant class >> bool: aBoolean [
	^ self type: SLVMType boolType value: aBoolean
]

{ #category : #constructor }
SLVMConstant class >> cstring: value [
	^ SLVMStringConstantValue new
		type: (SLVMArrayType baseType: SLVMType charType elements: value size);
		hasExtraNullCharacter: true;
		value: value
]

{ #category : #constructor }
SLVMConstant class >> double: anInteger [
	^ self type: SLVMType doubleType value: anInteger
]

{ #category : #constructor }
SLVMConstant class >> float: anInteger [
	^ self type: SLVMType floatType value: anInteger
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
SLVMConstant class >> pointerToConstant: constant pointerType: pointerType [
	^ SLVMConstantPointer constant: constant pointerType: pointerType
]

{ #category : #constructor }
SLVMConstant class >> type: aSLVMType value: aConstantValue [ 
	^ SLVMConstantValue new type: aSLVMType; value: aConstantValue
]

{ #category : #constructor }
SLVMConstant class >> uint: anInteger [
	^ self type: SLVMType uintType value: anInteger
]

{ #category : #constructor }
SLVMConstant class >> ulong: anInteger [
	^ self type: SLVMType ulongType value: anInteger
]

{ #category : #testing }
SLVMConstant >> isConstant [
	^ true
]

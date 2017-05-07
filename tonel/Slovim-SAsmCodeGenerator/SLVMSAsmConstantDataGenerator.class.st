Class {
	#name : #SLVMSAsmConstantDataGenerator,
	#superclass : #SLVMSAsmConstantCodeGenerator,
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #visiting }
SLVMSAsmConstantDataGenerator >> visitConstantValue: constant [
	| type |
	type := constant type.
	type isScalarType ifTrue: [ 
		type isIntegerType ifTrue: [
			^ SAsmConstantExpressionConstantInteger new
				size: type size;
				value: constant value;
				yourself.
		].

		type isFloatType ifTrue: [
			^ SAsmConstantExpressionConstantFloat new
				size: type size;
				value: constant value;
				yourself.
		].
	].

	^ SAsmConstantExpressionConstantBlob new value: constant asBlob; yourself
]

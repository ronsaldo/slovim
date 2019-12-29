Class {
	#name : #LLVMVectorType,
	#superclass : #LLVMSequentialType,
	#category : #'LLVM-IR-Types'
}

{ #category : #accessing }
LLVMVectorType >> bits [
	^ elementType bits
]

{ #category : #accessing }
LLVMVectorType >> constant: constantElements [
	self assert: constantElements size = elements.
	^ LLVMConstantVector new
		type: self;
		elements: constantElements;
		yourself
]

{ #category : #'as yet unclassified' }
LLVMVectorType >> constantScalarValue: scalarValue [
	| element |
	element := elementType constantScalarValue: scalarValue.
	^ LLVMConstantVector new
		type: self;
		elements: ((1 to: elements) collect: [:i | element]);
		yourself
]

{ #category : #accessing }
LLVMVectorType >> createName [
	^ ByteString streamContents: [ :out |
		out nextPut: $<; print: elements; nextPutAll: ' x ' ; print: elementType; nextPut: $>
	]
]

{ #category : #testing }
LLVMVectorType >> isVectorTy [
	^ true
]

{ #category : #'as yet unclassified' }
LLVMVectorType >> minusOneConstant [
	| oneElement |
	oneElement := elementType minusOneConstant.
	^ LLVMConstantVector new
		type: self;
		elements: ((1 to: elements) collect: [:i | oneElement]);
		yourself
]

{ #category : #'as yet unclassified' }
LLVMVectorType >> oneConstant [
	| oneElement |
	oneElement := elementType oneConstant.
	^ LLVMConstantVector new
		type: self;
		elements: ((1 to: elements) collect: [:i | oneElement]);
		yourself
]

{ #category : #'as yet unclassified' }
LLVMVectorType >> overloadedIntrinsicName [
	^ 'v', elements asString, elementType overloadedIntrinsicName
]

{ #category : #'as yet unclassified' }
LLVMVectorType >> zeroConstant [
	| zeroElement |
	zeroElement := elementType zeroConstant.
	^ LLVMConstantVector new
		type: self;
		elements: ((1 to: elements) collect: [:i | zeroElement]);
		yourself
]

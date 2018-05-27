Class {
	#name : #LLVMVectorType,
	#superclass : #LLVMSequentialType,
	#category : #'LLVM-IR-Types'
}

{ #category : #accessing }
LLVMVectorType >> createName [
	^ ByteString streamContents: [ :out |
		out nextPut: $<; print: elements; nextPutAll: ' x ' ; print: elementType; nextPut: $>
	]
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

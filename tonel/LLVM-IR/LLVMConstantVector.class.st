Class {
	#name : #LLVMConstantVector,
	#superclass : #LLVMConstantAggregate,
	#category : #'LLVM-IR-Constants'
}

{ #category : #accessing }
LLVMConstantVector >> buildHandle [
	handle := type elementType validHandle constVector: (LLVMValueRefArray withAll: elements) getHandle count: elements size.
]

{ #category : #'as yet unclassified' }
LLVMConstantVector >> convertIntoCompactVectorType: compactVectorType [
	self assert: compactVectorType elements = elements size.
	^ LLVMConstantArray new
		type: compactVectorType;
		elements: elements;
		yourself
]

{ #category : #printing }
LLVMConstantVector >> printOn: aStream [
	aStream nextPut: $<.
	elements doWithIndex: [ :element :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: element type; space; print: element
	].
	aStream nextPut: $>.
]

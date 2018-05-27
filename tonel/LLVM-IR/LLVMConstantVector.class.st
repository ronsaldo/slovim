Class {
	#name : #LLVMConstantVector,
	#superclass : #LLVMConstantAggregate,
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMConstantVector >> printOn: aStream [
	aStream nextPut: $<.
	elements doWithIndex: [ :element :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: element type; space; print: element
	].
	aStream nextPut: $>.
]

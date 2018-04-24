Class {
	#name : #LLVMConstantStruct,
	#superclass : #LLVMConstantAggregate,
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMConstantStruct >> printOn: aStream [
	aStream nextPut: ${.
	elements doWithIndex: [ :element :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: element type; space; print: element
	].
	aStream nextPut: $}.
]

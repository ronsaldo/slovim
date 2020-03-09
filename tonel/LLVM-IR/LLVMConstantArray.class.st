Class {
	#name : #LLVMConstantArray,
	#superclass : #LLVMConstantAggregate,
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMConstantArray >> printOn: aStream [
	aStream nextPut: $[.
	elements doWithIndex: [ :element :index |
		index > 1 ifTrue: [
			index % 20 = 0 ifTrue: [ 
				aStream nextPut: $,; lf
			] ifFalse: [ 
				aStream nextPutAll: ', '
			].
		].
		aStream print: element type; space; print: element
	].
	aStream nextPut: $].
]

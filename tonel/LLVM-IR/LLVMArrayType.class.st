Class {
	#name : #LLVMArrayType,
	#superclass : #LLVMSequentialType,
	#category : #'LLVM-IR-Types'
}

{ #category : #accessing }
LLVMArrayType >> createName [
	^ ByteString streamContents: [ :out |
		out nextPut: $[; print: elements; nextPutAll: ' x ' ; print: elementType; nextPut: $]
	]
]

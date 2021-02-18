Class {
	#name : #LLVMConstantZeroInitializer,
	#superclass : #LLVMConstant,
	#category : #'LLVM-IR-Constants'
}

{ #category : #accessing }
LLVMConstantZeroInitializer >> buildHandle [
	handle := type validHandle constNull
]

{ #category : #'as yet unclassified' }
LLVMConstantZeroInitializer >> convertIntoCompactVectorType: compactVectorType [
	^ self copy type: compactVectorType; yourself
]

{ #category : #printing }
LLVMConstantZeroInitializer >> printOn: aStream [
	aStream nextPutAll: 'zeroinitializer'
]

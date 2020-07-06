Class {
	#name : #LLVMUndefValue,
	#superclass : #LLVMConstantData,
	#category : #'LLVM-IR-Constants'
}

{ #category : #'as yet unclassified' }
LLVMUndefValue >> convertIntoCompactVectorType: compactVectorType [
	^ self copy type: compactVectorType; yourself
]

{ #category : #printing }
LLVMUndefValue >> printOn: aStream [
	^ aStream nextPutAll: 'undef'
]

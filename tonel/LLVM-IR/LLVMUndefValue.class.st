Class {
	#name : #LLVMUndefValue,
	#superclass : #LLVMConstantData,
	#category : #'LLVM-IR-Constants'
}

{ #category : #accessing }
LLVMUndefValue >> buildHandle [
	handle := type validHandle getUndef
]

{ #category : #'as yet unclassified' }
LLVMUndefValue >> convertIntoCompactVectorType: compactVectorType [
	^ self copy type: compactVectorType; yourself
]

{ #category : #testing }
LLVMUndefValue >> isUndefValue [
	^ true
]

{ #category : #printing }
LLVMUndefValue >> printOn: aStream [
	^ aStream nextPutAll: 'undef'
]

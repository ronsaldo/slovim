Class {
	#name : #LLVMGetElementPtrConstantExpr,
	#superclass : #LLVMConstantExpr,
	#instVars : [
		'pointer',
		'indices',
		'inbounds'
	],
	#category : #'LLVM-IR-Constants'
}

{ #category : #accessing }
LLVMGetElementPtrConstantExpr >> buildHandle [
	handle := inbounds
		ifTrue: [ pointer validHandle constInBoundsGEPIndices: (LLVMValueRefArray withAll: indices) getHandle count: indices size ]
		ifFalse: [ pointer validHandle constGEPIndices: (LLVMValueRefArray withAll: indices) getHandle count: indices size ].
]

{ #category : #accessing }
LLVMGetElementPtrConstantExpr >> inbounds [
	^ inbounds
]

{ #category : #accessing }
LLVMGetElementPtrConstantExpr >> inbounds: anObject [
	inbounds := anObject
]

{ #category : #accessing }
LLVMGetElementPtrConstantExpr >> indices [
	^ indices
]

{ #category : #accessing }
LLVMGetElementPtrConstantExpr >> indices: anObject [
	indices := anObject
]

{ #category : #initialization }
LLVMGetElementPtrConstantExpr >> initialize [
	super initialize.
	inbounds := false.
	
]

{ #category : #accessing }
LLVMGetElementPtrConstantExpr >> pointer [
	^ pointer
]

{ #category : #accessing }
LLVMGetElementPtrConstantExpr >> pointer: anObject [
	pointer := anObject
]

{ #category : #printing }
LLVMGetElementPtrConstantExpr >> printOn: aStream [
	aStream nextPutAll: 'getelementptr '.
	inbounds ifTrue: [ aStream nextPutAll: 'inbounds ' ].
	aStream nextPut: $(; print: pointer type elementType;
		nextPutAll: ', '; print: pointer type; print: pointer.
	indices do: [ :index |
		aStream nextPutAll: ', '; print: index type; space; print: index
	].
	aStream nextPut: $).
]

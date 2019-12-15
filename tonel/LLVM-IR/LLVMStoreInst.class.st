Class {
	#name : #LLVMStoreInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'value',
		'pointer',
		'volatile',
		'atomic',
		'ordering',
		'align'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMStoreInst >> align [
	^ align
]

{ #category : #accessing }
LLVMStoreInst >> align: anObject [
	align := anObject
]

{ #category : #accessing }
LLVMStoreInst >> atomic [
	^ atomic
]

{ #category : #accessing }
LLVMStoreInst >> atomic: anObject [
	atomic := anObject
]

{ #category : #initialization }
LLVMStoreInst >> initialize [
	super initialize.
	volatile := false.
	atomic := false.
	ordering := #unordered.
]

{ #category : #printing }
LLVMStoreInst >> mnemonic [
	^ #store
]

{ #category : #accessing }
LLVMStoreInst >> ordering [
	^ ordering
]

{ #category : #accessing }
LLVMStoreInst >> ordering: anObject [
	ordering := anObject
]

{ #category : #accessing }
LLVMStoreInst >> pointer [
	^ pointer
]

{ #category : #accessing }
LLVMStoreInst >> pointer: anObject [
	pointer := anObject
]

{ #category : #printing }
LLVMStoreInst >> printParametersOn: aStream [
	atomic ifTrue: [ aStream nextPutAll: ' atomic' ].
	volatile ifTrue: [ aStream nextPutAll: ' volatile' ].
	aStream space; print: value type; space; print: value.
	aStream nextPutAll: ', '; print: pointer type; space; print: pointer.
	atomic ifTrue: [ aStream space; nextPutAll: ordering ].
	align ifNotNil: [ aStream nextPutAll: ', align '; print: align ].

]

{ #category : #accessing }
LLVMStoreInst >> value [
	^ value
]

{ #category : #accessing }
LLVMStoreInst >> value: anObject [
	value := anObject
]

{ #category : #accessing }
LLVMStoreInst >> volatile [
	^ volatile
]

{ #category : #accessing }
LLVMStoreInst >> volatile: anObject [
	volatile := anObject
]

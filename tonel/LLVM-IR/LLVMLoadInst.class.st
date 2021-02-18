Class {
	#name : #LLVMLoadInst,
	#superclass : #LLVMUnaryInstruction,
	#instVars : [
		'pointer',
		'volatile',
		'atomic',
		'ordering',
		'align'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #accessing }
LLVMLoadInst >> align [
	^ align
]

{ #category : #accessing }
LLVMLoadInst >> align: anObject [
	align := anObject
]

{ #category : #accessing }
LLVMLoadInst >> atomic [
	^ atomic
]

{ #category : #accessing }
LLVMLoadInst >> atomic: anObject [
	atomic := anObject
]

{ #category : #'as yet unclassified' }
LLVMLoadInst >> buildHandleWithBuilder: builder [
	handle := builder load: pointer validHandle name: name llvmNameForHandle.
	handle setVolatile: volatile.
	atomic ifTrue: [ handle setOrdering: (AtomicOrderingMap at: ordering) ].
	align ifNotNil: [ handle setAlignment: align ]
]

{ #category : #accessing }
LLVMLoadInst >> initialize [
	super initialize.
	volatile := false.
	atomic := false.
	ordering := #unordered.
]

{ #category : #printing }
LLVMLoadInst >> mnemonic [
	^ #load
]

{ #category : #accessing }
LLVMLoadInst >> ordering [
	^ ordering
]

{ #category : #accessing }
LLVMLoadInst >> ordering: anObject [
	ordering := anObject
]

{ #category : #accessing }
LLVMLoadInst >> pointer [
	^ pointer
]

{ #category : #accessing }
LLVMLoadInst >> pointer: anObject [
	pointer := anObject
]

{ #category : #printing }
LLVMLoadInst >> printParametersOn: aStream [
	atomic ifTrue: [ aStream nextPutAll: ' atomic' ].
	volatile ifTrue: [ aStream nextPutAll: ' volatile' ].
	aStream space; print: type; nextPutAll: ', '; print: pointer type; space; print: pointer.
	atomic ifTrue: [ aStream space; nextPutAll: ordering ].
	align ifNotNil: [ aStream nextPutAll: ', align '; print: align ].

]

{ #category : #accessing }
LLVMLoadInst >> volatile [
	^ volatile
]

{ #category : #accessing }
LLVMLoadInst >> volatile: anObject [
	volatile := anObject
]

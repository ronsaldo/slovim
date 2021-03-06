Class {
	#name : #LLVMAtomicCmpXchgInst,
	#superclass : #LLVMInstruction,
	#instVars : [
		'pointer',
		'newValue',
		'failureOrdering',
		'comparisonValue',
		'successOrdering'
	],
	#category : #'LLVM-IR-Instructions'
}

{ #category : #'as yet unclassified' }
LLVMAtomicCmpXchgInst >> buildHandleWithBuilder: builder [
	handle := builder atomicPointer: pointer validHandle cmp: comparisonValue validHandle xchg: newValue validHandle successOrdering: (AtomicOrderingMap at: successOrdering) failureOrdering: (AtomicOrderingMap at: failureOrdering) singleThread: false
]

{ #category : #accessing }
LLVMAtomicCmpXchgInst >> comparisonValue [
	^ comparisonValue
]

{ #category : #accessing }
LLVMAtomicCmpXchgInst >> comparisonValue: anObject [
	comparisonValue := anObject
]

{ #category : #accessing }
LLVMAtomicCmpXchgInst >> failureOrdering [
	^ failureOrdering
]

{ #category : #accessing }
LLVMAtomicCmpXchgInst >> failureOrdering: anObject [
	failureOrdering := anObject
]

{ #category : #initialization }
LLVMAtomicCmpXchgInst >> initialize [
	super initialize.
	successOrdering := #monotonic.
	failureOrdering := #monotonic.
]

{ #category : #printing }
LLVMAtomicCmpXchgInst >> mnemonic [
	^ #cmpxchg
]

{ #category : #accessing }
LLVMAtomicCmpXchgInst >> newValue [
	^ newValue
]

{ #category : #accessing }
LLVMAtomicCmpXchgInst >> newValue: anObject [
	newValue := anObject
]

{ #category : #accessing }
LLVMAtomicCmpXchgInst >> ordering: anOrdering [
	(#(#release acq_rel) includes: anOrdering) ifTrue: [ 
		self
			failureOrdering: #acquire;
			successOrdering: #release
	] ifFalse: [ 
		self
			failureOrdering: anOrdering;
			successOrdering: anOrdering
	].

]

{ #category : #accessing }
LLVMAtomicCmpXchgInst >> pointer [
	^ pointer
]

{ #category : #accessing }
LLVMAtomicCmpXchgInst >> pointer: anObject [
	pointer := anObject
]

{ #category : #printing }
LLVMAtomicCmpXchgInst >> printParametersOn: aStream [
	aStream
		space; print: pointer type; space; print: pointer;
		nextPutAll: ', '; print: comparisonValue type; space; print: comparisonValue;
		nextPutAll: ', '; print: newValue type; space; print: newValue;
		space; nextPutAll: successOrdering; space; nextPutAll: failureOrdering
]

{ #category : #accessing }
LLVMAtomicCmpXchgInst >> successOrdering [
	^ successOrdering
]

{ #category : #accessing }
LLVMAtomicCmpXchgInst >> successOrdering: anObject [
	successOrdering := anObject
]

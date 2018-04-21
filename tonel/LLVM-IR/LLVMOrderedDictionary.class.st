Class {
	#name : #LLVMOrderedDictionary,
	#superclass : #OrderedDictionary,
	#category : #'LLVM-IR'
}

{ #category : #accessing }
LLVMOrderedDictionary >> at: aKey ifPresent: aPresentBlock ifAbsentPut: anAbsentBlock [
	^ dictionary
		at: aKey
		ifPresent: aPresentBlock
		ifAbsent: [self at: aKey put: anAbsentBlock value]
]

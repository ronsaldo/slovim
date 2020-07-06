Class {
	#name : #LLVMArrayType,
	#superclass : #LLVMSequentialType,
	#category : #'LLVM-IR-Types'
}

{ #category : #accessing }
LLVMArrayType >> constant: constantElements [
	self assert: constantElements size = elements.
	^ LLVMConstantArray new
		type: self;
		elements: constantElements;
		yourself
]

{ #category : #accessing }
LLVMArrayType >> createName [
	^ ByteString streamContents: [ :out |
		out nextPut: $[; print: elements; nextPutAll: ' x ' ; print: elementType; nextPut: $]
	]
]

{ #category : #testing }
LLVMArrayType >> isArrayTy [
	^ true
]

{ #category : #accessing }
LLVMArrayType >> memberAt: index [
	^ elementType
]

{ #category : #accessing }
LLVMArrayType >> totalElementCount [
	^ elementType totalElementCount * elements
]

{ #category : #'as yet unclassified' }
LLVMArrayType >> validateNonRecursiveChildrenWith: visitedSet [
	(visitedSet includes: self) ifTrue: [ self error: 'Recursive array definition.' ].
	visitedSet add: self.
	elementType validateNonRecursionWith: visitedSet.

]

{ #category : #'as yet unclassified' }
LLVMArrayType >> zeroConstant [
	| zeroElement |
	zeroElement := elementType zeroConstant.
	^ LLVMConstantArray new
		type: self;
		elements: ((1 to: elements) collect: [:i | zeroElement]);
		yourself
]

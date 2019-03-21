"
I perform stack based allocations for local variables.

Alloca instructions placed in the first basic block of a function are usually optimized in an special way.
"
Class {
	#name : #SLVMAlloca,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type',
		'valueType'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMAlloca class >> pointerSize: pointerSize valueType: valueType [
	^ self new pointerSize: pointerSize valueType: valueType
]

{ #category : #visitor }
SLVMAlloca >> accept: aVisitor [
	^ aVisitor visitAlloca: self
]

{ #category : #printing }
SLVMAlloca >> fullPrintOn: aStream [
	self printOn: aStream.
	aStream nextPutAll: ' = '; putKeyword: #alloca; space;
		print: type
]

{ #category : #testing }
SLVMAlloca >> isAlloca [
	^ true
]

{ #category : #accessing }
SLVMAlloca >> isOnlyUsedByLoadStore [
	self instructionReferences do: [ :ref |
		ref isLoad ifFalse: [
			ref isStore ifTrue: [
				ref value == self ifTrue: [ ^ false ].
				self assert: ref variable == self.
			] ifFalse: [
				^ false
			].
		].
	].

	^ true
]

{ #category : #accessing }
SLVMAlloca >> isOnlyUsedByLoadStoreAndGetElementPtrBase [
	self instructionReferences do: [ :ref |
		ref isLoad ifFalse: [
			ref isStore ifTrue: [
				ref value == self ifTrue: [ ^ false ].
				self assert: ref variable == self.
			] ifFalse: [
				ref isGetElementPointer ifFalse: [ ^ false ].
				ref indices do: [ :index | index == self ifTrue: [ ^ false ] ].
				self assert: ref pointer == self.
			].
		].
	].

	^ true
]

{ #category : #printing }
SLVMAlloca >> mnemonic [
	^ #alloca
]

{ #category : #accessing }
SLVMAlloca >> pointerSize: pointerSize valueType: aType [
	self assert: aType isSlovimType.
	valueType := aType.
	type := SLVMPointerType size: pointerSize baseType: valueType storage: SLVMType functionStorage
]

{ #category : #accessing }
SLVMAlloca >> type [
	^ type
]

{ #category : #accessing }
SLVMAlloca >> valueType [
	^ valueType
]

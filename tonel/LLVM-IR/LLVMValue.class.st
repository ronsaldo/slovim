Class {
	#name : #LLVMValue,
	#superclass : #LLVMObject,
	#instVars : [
		'name',
		'type'
	],
	#category : #'LLVM-IR'
}

{ #category : #converting }
LLVMValue >> asLLVMMetadata [
	^ LLVMLocalAsMetadata new value: self
]

{ #category : #converting }
LLVMValue >> asLLVMValueFor: aContext [
	self assert: type context == aContext.
	^ self
]

{ #category : #accessing }
LLVMValue >> context [
	^ type context
]

{ #category : #testing }
LLVMValue >> hasName [
	^ name isString
]

{ #category : #testing }
LLVMValue >> isAlloca [
	^ false
]

{ #category : #accessing }
LLVMValue >> name [
	^ name
]

{ #category : #accessing }
LLVMValue >> name: newName [
	name ifNotNil: [
		self error: 'Cannot change name now.'
	].
	name := newName.

]

{ #category : #printing }
LLVMValue >> printOn: aStream [
	aStream nextPut: $%.
	name llvmPrintNameOn: aStream.
]

{ #category : #accessing }
LLVMValue >> type [
	^ type
]

{ #category : #accessing }
LLVMValue >> type: anObject [
	type := anObject
]

Class {
	#name : #LLVMValueProxy,
	#superclass : #Object,
	#instVars : [
		'proxiedValue'
	],
	#category : #'LLVM-IR'
}

{ #category : #'reflective operations' }
LLVMValueProxy >> doesNotUnderstand: aMessage [
	proxiedValue ifNil: [ self error: 'Invalid proxy' ].
	^ aMessage sendTo: proxiedValue
]

{ #category : #accessing }
LLVMValueProxy >> proxiedValue [
	^ proxiedValue
]

{ #category : #accessing }
LLVMValueProxy >> proxiedValue: anObject [
	proxiedValue := anObject
]

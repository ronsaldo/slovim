Class {
	#name : #LLVMConstantFP,
	#superclass : #LLVMConstantData,
	#instVars : [
		'value'
	],
	#category : #'LLVM-IR-Constants'
}

{ #category : #printing }
LLVMConstantFP >> printOn: aStream [
	| ieee64 |
	(value isNaN or: [value isInfinite]) ifTrue: [
		ieee64 := ((value basicAt: 1) << 32) | (value basicAt: 2)  .
		aStream nextPutAll: '0x'; nextPutAll: (ieee64 printStringBase: 16 length: 16 padded: true)
	] ifFalse: [ 
		aStream print: value
	]

]

{ #category : #accessing }
LLVMConstantFP >> value [
	^ value
]

{ #category : #accessing }
LLVMConstantFP >> value: anObject [
	value := anObject
]

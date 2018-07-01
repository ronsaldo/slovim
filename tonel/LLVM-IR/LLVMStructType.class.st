Class {
	#name : #LLVMStructType,
	#superclass : #LLVMCompositeType,
	#instVars : [
		'elements'
	],
	#category : #'LLVM-IR-Types'
}

{ #category : #'as yet unclassified' }
LLVMStructType class >> context: context elements: elements [
	^ context typeAt: { self . elements }
		ifAbsentPut: [ self new
				context: context;
				elements: elements;
				yourself ]
]

{ #category : #printing }
LLVMStructType >> createName [
	^ ByteString streamContents: [ :out |
		out nextPutAll: '{'.
		elements doWithIndex: [ :element :index |
			index > 1 ifTrue: [ out nextPutAll: ', ' ].
			out print: element
		].
		out nextPut: $}
	]
]

{ #category : #accessing }
LLVMStructType >> elements [
	^ elements
]

{ #category : #accessing }
LLVMStructType >> elements: anObject [
	elements := anObject
]

{ #category : #printing }
LLVMStructType >> fullPrintOn: aStream [
	aStream print: self; nextPutAll: ' = '.
	self printDefinitionOn: aStream
]

{ #category : #accessing }
LLVMStructType >> memberAt: sourceIndex [
	^ elements at: sourceIndex + 1
]

{ #category : #accessing }
LLVMStructType >> name [
	^ name ifNil: [ name := self createName ]
]

{ #category : #printing }
LLVMStructType >> printDefinitionOn: aStream [
	elements ifNil: [ 
		aStream nextPutAll: 'type opaque'.
		^ self
	].

	aStream nextPutAll: 'type {'.
	elements doWithIndex: [ :element :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: element
	].
	aStream nextPut: $}
]

{ #category : #'as yet unclassified' }
LLVMStructType >> zeroConstant [
	^ LLVMConstantStruct new
		type: self;
		elements: (elements collect: [:elementType | elementType zeroConstant]);
		yourself
]

Class {
	#name : #LLVMStructType,
	#superclass : #LLVMCompositeType,
	#instVars : [
		'elements',
		'packed',
		'inlineDefinitionString'
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

{ #category : #'as yet unclassified' }
LLVMStructType >> computeMemberTypeFor: elementIndex [
	self assert: elementIndex value isInteger.
	^ (elements at: elementIndex value + 1)
]

{ #category : #'as yet unclassified' }
LLVMStructType >> constant: constantElements [
	^ LLVMConstantStruct new
		type: self;
		elements: constantElements;
		yourself
]

{ #category : #'as yet unclassified' }
LLVMStructType >> elementAtConstIndex: constIndex [
	^ elements at: constIndex + 1
	
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
LLVMStructType >> hasAlreadyGeneratedName [
	^ name isNotNil
]

{ #category : #initialization }
LLVMStructType >> initialize [
	super initialize.
	packed := false.
	
]

{ #category : #printing }
LLVMStructType >> inlineDefinitionString [
	^ inlineDefinitionString ifNil: [
		self validateNonRecursion. inlineDefinitionString := ByteString streamContents: [ :out |
			out nextPutAll: '{'.
			elements doWithIndex: [ :element :index |
				index > 1 ifTrue: [ out nextPutAll: ', ' ].
				out print: element
			].
			out nextPut: $}
		]
	]
]

{ #category : #testing }
LLVMStructType >> isStructTy [
	^ true
]

{ #category : #accessing }
LLVMStructType >> memberAt: sourceIndex [
	^ elements at: sourceIndex + 1
]

{ #category : #accessing }
LLVMStructType >> name [
	^ name
]

{ #category : #accessing }
LLVMStructType >> packed [
	^ packed
]

{ #category : #accessing }
LLVMStructType >> packed: anObject [
	packed := anObject
]

{ #category : #printing }
LLVMStructType >> printDefinitionOn: aStream [
	elements ifNil: [ 
		aStream nextPutAll: 'type opaque'.
		^ self
	].

	packed ifTrue: [ 
		aStream nextPutAll: 'type <{'.
	] ifFalse: [
		aStream nextPutAll: 'type {'.
	].

	elements doWithIndex: [ :element :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: element
	].

	aStream nextPut: $}. packed ifTrue: [ aStream nextPut: $> ].
]

{ #category : #composition }
LLVMStructType >> printOn: aStream [
	name ifNotNil: [ 
		aStream nextPut: $%; nextPutAll: name.
	] ifNil: [
		aStream nextPutAll: self inlineDefinitionString
	].

]

{ #category : #'as yet unclassified' }
LLVMStructType >> validateNonRecursiveChildrenWith: visitedSet [
	(visitedSet includes: self) ifTrue: [ self error: 'Recursive structure definition.' ].
	visitedSet add: self.
	elements do: [ :el | el validateNonRecursionWith: visitedSet ].

]

{ #category : #'as yet unclassified' }
LLVMStructType >> zeroConstant [
	^ LLVMConstantStruct new
		type: self;
		elements: (elements collect: [:elementType | elementType zeroConstant]);
		yourself
]

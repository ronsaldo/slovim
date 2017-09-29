Class {
	#name : #SLVMETreeStatement,
	#superclass : #SLVMETreeNode,
	#instVars : [
		'name',
		'slvmInstruction',
		'expression',
		'references',
		'block',
		'previous',
		'next'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #adding }
SLVMETreeStatement >> addReference: aReference [
	references := references copyWith: aReference
]

{ #category : #adding }
SLVMETreeStatement >> addReferencesToOperands [
	expression parameters do: [ :param |
		param isStatement ifTrue: [
			param addReference: self
		]
	]
]

{ #category : #accessing }
SLVMETreeStatement >> block [
	^ block
]

{ #category : #accessing }
SLVMETreeStatement >> block: anObject [
	block := anObject
]

{ #category : #accessing }
SLVMETreeStatement >> expression [
	^ expression
]

{ #category : #accessing }
SLVMETreeStatement >> expression: anObject [
	expression := anObject
]

{ #category : #printing }
SLVMETreeStatement >> fullPrintOn: aStream [
	name ifNotNil: [ 
		aStream putIdentifier: self validName; nextPutAll: ' := '
	].

	expression ifNotNil: [ expression fullPrintOn: aStream ]

]

{ #category : #initialization }
SLVMETreeStatement >> initialize [
	super initialize.
	
	references := #().
	
]

{ #category : #testing }
SLVMETreeStatement >> isStatement [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMETreeStatement >> mergePreviousExpressions [
	| parameters param |
	self assert: expression isNotNil.
	parameters := expression parameters.
	parameters size to: 1 by: -1 do: [ :i |
		param := parameters at: i.
		(param isStatement and: [ param references size == 1 and: [ param == previous ] ]) ifTrue: [
			param removeFromBlock.
			parameters at: i put: param expression.
		]
	]
]

{ #category : #accessing }
SLVMETreeStatement >> name [
	^ name
]

{ #category : #accessing }
SLVMETreeStatement >> name: anObject [
	name := anObject
]

{ #category : #accessing }
SLVMETreeStatement >> next [
	^ next
]

{ #category : #accessing }
SLVMETreeStatement >> next: anObject [
	next := anObject
]

{ #category : #printing }
SLVMETreeStatement >> prettyPrintOn: aStream [
	aStream putIdentifier: self validName
]

{ #category : #accessing }
SLVMETreeStatement >> previous [
	^ previous
]

{ #category : #accessing }
SLVMETreeStatement >> previous: anObject [
	previous := anObject
]

{ #category : #printing }
SLVMETreeStatement >> printOn: aStream [
	aStream nextPutAll: self validName
]

{ #category : #accessing }
SLVMETreeStatement >> references [
	^ references
]

{ #category : #removing }
SLVMETreeStatement >> removeFromBlock [
	block removeStatement: self
]

{ #category : #accessing }
SLVMETreeStatement >> slvmInstruction [
	^ slvmInstruction
]

{ #category : #accessing }
SLVMETreeStatement >> slvmInstruction: anObject [
	slvmInstruction := anObject
]

{ #category : #accessing }
SLVMETreeStatement >> validName [
	^ name ifNil: [ #anonv ]
]

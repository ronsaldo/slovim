Class {
	#name : #SLVMETreeBasicBlock,
	#superclass : #SLVMETreeNode,
	#instVars : [
		'name',
		'index',
		'lastStatement',
		'firstStatement'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #adding }
SLVMETreeBasicBlock >> add: aStatement [
	^ self addLast: aStatement
]

{ #category : #adding }
SLVMETreeBasicBlock >> addLast: aStatement [
	self assert: (aStatement previous isNil and: [ aStatement next isNil ]).
	self assert: aStatement block isNil.
	aStatement block: self.
	
	aStatement previous: lastStatement.
	lastStatement ifNil: [ 
		firstStatement := aStatement
	] ifNotNil: [
		lastStatement next: aStatement
	].
	lastStatement := aStatement.

	^ aStatement
]

{ #category : #printing }
SLVMETreeBasicBlock >> fullPrintOn: aStream [
	aStream putIdentifier: self validName; nextPutAll: ':'; cr.
	self statementsDo: [ :expr |
		aStream tab.
		expr fullPrintOn: aStream.
		aStream cr
	]
]

{ #category : #accessing }
SLVMETreeBasicBlock >> index [
	^ index
]

{ #category : #accessing }
SLVMETreeBasicBlock >> index: anObject [
	index := anObject
]

{ #category : #initialization }
SLVMETreeBasicBlock >> initialize [
	super initialize.
]

{ #category : #testing }
SLVMETreeBasicBlock >> isLastBranch [
	^ lastStatement isNotNil and: [ lastStatement expression isBranch ]
]

{ #category : #accessing }
SLVMETreeBasicBlock >> lastExpression [
	^ lastStatement expression
]

{ #category : #accessing }
SLVMETreeBasicBlock >> lastStatement [
	^ lastStatement
]

{ #category : #accessing }
SLVMETreeBasicBlock >> name [
	^ name
]

{ #category : #accessing }
SLVMETreeBasicBlock >> name: anObject [
	name := anObject
]

{ #category : #removing }
SLVMETreeBasicBlock >> removeStatement: anStatement [
	self assert: anStatement block == self.
	anStatement previous ifNil: [
		firstStatement := anStatement next.
	] ifNotNil: [
		anStatement previous next: anStatement next.
	].

	anStatement next ifNil: [
		lastStatement := anStatement previous.
	] ifNotNil: [
		anStatement next previous: anStatement previous.
	].

	anStatement
		previous: nil;
		next: nil;
		block: nil.

]

{ #category : #accessing }
SLVMETreeBasicBlock >> statementsDo: aBlock [
	| nextStatement currentStatement |
	nextStatement := firstStatement.
	[ nextStatement ] whileNotNil: [
		currentStatement := nextStatement.
		nextStatement := nextStatement next.
		aBlock value: currentStatement
	]
]

{ #category : #accessing }
SLVMETreeBasicBlock >> validName [
	^ name ifNil: [ #anonymous ]
]

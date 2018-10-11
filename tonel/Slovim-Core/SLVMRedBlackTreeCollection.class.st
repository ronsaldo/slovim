"
I am a left-leaning red-black tree. I implement the algorithm that is described in the following paper:

  Sedgewick, Robert. ""Left-leaning red-black trees."" Dagstuhl Workshop on Data Structures. 2008.

This algorithm is choosen for simplicity, and because the paper includes source code in Java that can be easily adapted.
"
Class {
	#name : #SLVMRedBlackTreeCollection,
	#superclass : #Collection,
	#instVars : [
		'root',
		'size'
	],
	#classVars : [
		'Black',
		'Red'
	],
	#category : #'Slovim-Core-Collections'
}

{ #category : #'class initialization' }
SLVMRedBlackTreeCollection class >> initialize [
	Red := true.
	Black := false.
	
]

{ #category : #adding }
SLVMRedBlackTreeCollection >> add: aValue [
	root := self insertKey: aValue value: aValue from: root.
	root color: Black
]

{ #category : #converting }
SLVMRedBlackTreeCollection >> asArray [
	| array destIndex |
	array := Array new: size.
	destIndex := 1.
	self do: [ :value |
		array at: destIndex put: value.
		destIndex := destIndex + 1
	].

	^ array
]

{ #category : #'red black tree' }
SLVMRedBlackTreeCollection >> colorFlip: h [
	h color: h color not.
	h left color: h left color not.
	h right color: h right color not.
]

{ #category : #'red black tree' }
SLVMRedBlackTreeCollection >> deleteKey: key [
	root := self deleteKey: key from: root.
	root color: Black
]

{ #category : #'red black tree' }
SLVMRedBlackTreeCollection >> deleteKey: key from: node [
	| h hkey equal |
	h := node.
	hkey := h key.
	key < hkey ifTrue: [
		((self isRed: h left) not and: [ (self isRed: h left left) not]) ifTrue: [ 
			h := self moveRedLeft: h
		].
		h left: (self deleteKey: key from: h left)
	] ifFalse: [
		(self isRed: h left) ifTrue: [
			h := self rotateRight: h
		].
	
		equal := (hkey < key) not.
		(equal and: [ h right == nil ]) ifTrue: [
			size := size - 1.
			^ nil
		].
		
		((self isRed: h right) not and: [ (self isRed: h right left ) not ]) ifTrue: [
			h := self moveRedRight: h
		].
	
		equal ifTrue: [
			h value: (self getMinNodeFrom: h right) value.
			h right: (self deleteMin: h right)
		] ifFalse: [
			h right: (self deleteKey: key from: h right)
		]
	].

	^ self fixUp: h
]

{ #category : #'red black tree' }
SLVMRedBlackTreeCollection >> deleteMin: node [
	| h |
	h := node.
	h left ifNil: [
		size := size - 1.
		^ nil
	].

	((self isRed: h left) not and: [ (self isRed: h left left) not ]) ifTrue: [
		h := self moveRedLeft: h
	].

	h left: (self deleteMin: h left).
	^ self fixUp: h
]

{ #category : #accessing }
SLVMRedBlackTreeCollection >> do: aBlock [
	root ifNotNil: [ root do: aBlock ]
]

{ #category : #accessing }
SLVMRedBlackTreeCollection >> firstNode [
	^ self getMinNodeFrom: root
]

{ #category : #'red black tree' }
SLVMRedBlackTreeCollection >> fixUp: node [
	| h |
	h := node.
	((self isRed: h right) and: [ (self isRed: h left) not]) ifTrue: [
		h := self rotateLeft: h
	].
	((self isRed: h left) and: [ self isRed: h left left]) ifTrue: [
		h := self rotateRight: h
	].
	((self isRed: h left) and: [ self isRed: h right ]) ifTrue: [ 
		self colorFlip: h
	].
	^ h
]

{ #category : #accessing }
SLVMRedBlackTreeCollection >> getMaxNodeFrom: node [
	| position bestResult |
	position := node.
	bestResult := node.
	[ position isNil ] whileFalse: [
		bestResult := position.
		position := position right
	].
	^ bestResult

]

{ #category : #accessing }
SLVMRedBlackTreeCollection >> getMinNodeFrom: node [
	| position bestResult |
	position := node.
	bestResult := node.
	[ position isNil ] whileFalse: [
		bestResult := position.
		position := position left
	].
	^ bestResult

]

{ #category : #'gt inspector extensions' }
SLVMRedBlackTreeCollection >> gtTreeViewIn: composite [
	<gtInspectorPresentationOrder: 9>
	self ifEmpty: [ ^ self ].
	composite tree 
		title: 'Red-Black Tree';
		display: [ :node | root ];
		children: [ :each | each childrenNodes ];
		format: [ :node | node printString ]
]

{ #category : #initialization }
SLVMRedBlackTreeCollection >> initialize [
	super initialize.
	size := 0.
]

{ #category : #'red black tree' }
SLVMRedBlackTreeCollection >> insertKey: key value: aValue from: node [
	| hkey h |
	h := node.
	h ifNil: [ 
		size := size + 1.
		^ self nodeSpecies value: aValue color: Red
	].

	hkey := h key.
	key < hkey ifTrue: [ 
		h left: (self insertKey: key value: aValue from: h left)
	] ifFalse: [ 
		hkey < key ifTrue: [ 
			h right: (self insertKey: key value: aValue from: h right)
		] ifFalse: [
			h value: aValue
		]
	].

	^ self fixUp: h
]

{ #category : #'red black tree' }
SLVMRedBlackTreeCollection >> isRed: node [
	^ node isNotNil and: [node color == Red]
]

{ #category : #accessing }
SLVMRedBlackTreeCollection >> lastNode [
	^ self getMaxNodeFrom: root
]

{ #category : #'red black tree' }
SLVMRedBlackTreeCollection >> moveRedLeft: node [
	| h |
	h := node.
	self colorFlip: h.
	(self isRed: h right left) ifTrue: [
		h right: (self rotateRight: h right).
		h := self rotateLeft: h.
		self colorFlip: h.
	].

	^ h
]

{ #category : #'red black tree' }
SLVMRedBlackTreeCollection >> moveRedRight: node [
	| h |
	h := node.
	self colorFlip: h.
	(self isRed: h left left) ifTrue: [
		h := self rotateRight: h.
		self colorFlip: h.
	].

	^ h
]

{ #category : #adding }
SLVMRedBlackTreeCollection >> nodeSpecies [
	^ SLVMRedBlackTreeNode
]

{ #category : #removing }
SLVMRedBlackTreeCollection >> remove: oldObject ifAbsent: ifAbsentBlock [
	(self searchKey: oldObject from: root) ifNil: [
		^ ifAbsentBlock value
	].

	self deleteKey: oldObject.
	^ oldObject
]

{ #category : #'red black tree' }
SLVMRedBlackTreeCollection >> rotateLeft: h [
	| x |
	x := h right.
	h right: x left.
	x left: h.
	x color: h color.
	h color: Red.
	^ x
]

{ #category : #'red black tree' }
SLVMRedBlackTreeCollection >> rotateRight: h [
	| x |
	x := h left.
	h left: x right.
	x right: h.
	x color: h color.
	h color: Red.
	^ x
]

{ #category : #'red black tree' }
SLVMRedBlackTreeCollection >> searchKey: key from: node [
	| nodeKey position |
	position := node.
	[position ~~ nil] whileTrue: [ 
		nodeKey := node key.
		key < nodeKey ifTrue: [
			position := node left
		] ifFalse: [ 
			nodeKey < key ifTrue: [
				position := node right
			] ifFalse: [
				^ node
			]
		]
	].

	^ nil

]

{ #category : #accessing }
SLVMRedBlackTreeCollection >> size [
	^ size
]

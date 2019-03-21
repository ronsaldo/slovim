"
A SLVMBitmapTest is a test class for testing the behavior of SLVMBitmap
"
Class {
	#name : #SLVMBitmapTest,
	#superclass : #TestCase,
	#category : #'Slovim-Tests'
}

{ #category : #tests }
SLVMBitmapTest >> testClearColumn [
	| bitmap expectedValue |
	bitmap := SLVMBitmap width: 32 height: 16.
	bitmap clearColumn: 1.
	bitmap setColumn: 4.
	1 to: 16 do: [ :r |
		1 to: 32 do: [ :c |
			expectedValue := c == 4.
			self assert: (bitmap atRow: r column: c) equals: expectedValue
		]
	]
]

{ #category : #tests }
SLVMBitmapTest >> testComplement [
	| bitmap expectedValue newBitmap |
	bitmap := SLVMBitmap width: 32 height: 16.
	bitmap setRow: 2.
	bitmap setRow: 4.
	newBitmap := bitmap complement.

	1 to: 16 do: [ :r |
		expectedValue := r == 2 or: r == 4.
		1 to: 32 do: [ :c |
			self assert: (bitmap atRow: r column: c) equals: expectedValue.
			self assert: (newBitmap atRow: r column: c) equals: expectedValue not.
		]
	]
]

{ #category : #tests }
SLVMBitmapTest >> testIntersection [
	|  leftBitmap rightBitmap resultBitmap leftExpected rightExpected expectedResult |
	leftBitmap := SLVMBitmap width: 32 height: 16.
	leftBitmap setRow: 2.
	leftBitmap setRow: 3.
	leftBitmap setRow: 4.

	rightBitmap := SLVMBitmap width: 32 height: 16.
	rightBitmap setRow: 3.
	rightBitmap setRow: 4.

	resultBitmap := leftBitmap intersection: rightBitmap.

	1 to: 16 do: [ :r |
		leftExpected := #(2 3 4) includes: r.
		rightExpected := #(3 4) includes: r.
		expectedResult := leftExpected and: rightExpected.
		1 to: 32 do: [ :c |
			self assert: (leftBitmap atRow: r column: c) equals: leftExpected.
			self assert: (rightBitmap atRow: r column: c) equals: rightExpected.
			self assert: (resultBitmap atRow: r column: c) equals: expectedResult.
		]
	]
]

{ #category : #tests }
SLVMBitmapTest >> testNew [
	| bitmap |
	bitmap := SLVMBitmap width: 32 height: 16.
	self assert: bitmap width equals: 32.
	self assert: bitmap height equals: 16.
	self assert: bitmap pitch <= 32.
	self assert: bitmap data isNotNil.
	1 to: 16 do: [ :r |
		1 to: 32 do: [ :c |
			self assert: (bitmap atRow: r column: c) equals: false
		]
	]
]

{ #category : #tests }
SLVMBitmapTest >> testSetColumn [
	| bitmap expectedValue |
	bitmap := SLVMBitmap width: 32 height: 16.
	bitmap setColumn: 2.
	bitmap setColumn: 4.
	1 to: 16 do: [ :r |
		1 to: 32 do: [ :c |
			expectedValue := c == 2 or: c == 4.
			self assert: (bitmap atRow: r column: c) equals: expectedValue
		]
	]
]

{ #category : #tests }
SLVMBitmapTest >> testSetRow [
	| bitmap expectedValue |
	bitmap := SLVMBitmap width: 32 height: 16.
	bitmap setRow: 2.
	bitmap setRow: 4.

	1 to: 16 do: [ :r |
		expectedValue := r == 2 or: r == 4.
		1 to: 32 do: [ :c |
			self assert: (bitmap atRow: r column: c) equals: expectedValue
		]
	]
]

{ #category : #tests }
SLVMBitmapTest >> testUnion [
	|  leftBitmap rightBitmap resultBitmap leftExpected rightExpected expectedResult |
	leftBitmap := SLVMBitmap width: 32 height: 16.
	leftBitmap setRow: 2.

	rightBitmap := SLVMBitmap width: 32 height: 16.
	rightBitmap setRow: 4.

	resultBitmap := leftBitmap union: rightBitmap.

	1 to: 16 do: [ :r |
		leftExpected := r == 2.
		rightExpected := r == 4.
		expectedResult := leftExpected or: rightExpected.
		1 to: 32 do: [ :c |
			self assert: (leftBitmap atRow: r column: c) equals: leftExpected.
			self assert: (rightBitmap atRow: r column: c) equals: rightExpected.
			self assert: (resultBitmap atRow: r column: c) equals: expectedResult.
		]
	]
]

"
A SLVMNativeArrayTest is a test class for testing the behavior of SLVMNativeArray
"
Class {
	#name : #SLVMNativeArrayTest,
	#superclass : #TestCase,
	#category : #'Slovim-Runtime-Tests'
}

{ #category : #tests }
SLVMNativeArrayTest >> testNativeArray [
	| array |
	array := SLVMNativeArray for: SLVMCompilationTargetTypes forCurrentImage int new: 10..
	1 to: 10 do: [ :i | array at: i put: i * 2 ].
	self assert: array asArray equals: #(2 4 6 8 10 12 14 16 18 20)
]

{ #category : #tests }
SLVMNativeArrayTest >> testNativeArray2 [
	| array |
	array := SLVMNativeArray for: #int new: 10..
	1 to: 10 do: [ :i | array at: i put: i * 2 ].
	self assert: array asArray equals: #(2 4 6 8 10 12 14 16 18 20).
	self assert: array rawData size equals: 40.
]

{ #category : #tests }
SLVMNativeArrayTest >> testNativeArray3 [
	| array |
	array := SLVMNativeArray for: #ushort new: 10.
	1 to: 10 do: [ :i | array at: i put: i * 2 ].
	self assert: array asArray equals: #(2 4 6 8 10 12 14 16 18 20).
	self assert: array rawData size equals: 20.

]

{ #category : #tests }
SLVMNativeArrayTest >> testNativeOrderedCollection [
	| collection |
	collection := SLVMNativeOrderedCollection for: SLVMCompilationTargetTypes forCurrentImage int.
	1 to: 10 do: [ :i | collection add: i * 2 ].
	self assert: collection asArray equals: #(2 4 6 8 10 12 14 16 18 20)
]

{ #category : #tests }
SLVMNativeArrayTest >> testNativeOrderedCollection2 [
	| collection |
	collection := SLVMNativeOrderedCollection for: #int.
	1 to: 10 do: [ :i | collection add: i * 2 ].
	self assert: collection asArray equals: #(2 4 6 8 10 12 14 16 18 20)
]

Class {
	#name : #SLVMOrderedSetTest,
	#superclass : #TestCase,
	#category : #'Slovim-Tests'
}

{ #category : #tests }
SLVMOrderedSetTest >> testEmpty [
	| set |
	set := SLVMOrderedSet new.
	self assert: set size equals: 0.
	self assert: set isEmpty.
]

{ #category : #tests }
SLVMOrderedSetTest >> testWithOneElement [
	| set |
	set := SLVMOrderedSet new
		add: 1;
		yourself.
	self assert: set size equals: 1.
	self assert: set isEmpty not.
	self assert: set isNotEmpty.
	self assert: set first equals: 1.
	self assert: set last equals: 1.
]

{ #category : #tests }
SLVMOrderedSetTest >> testWithThreeElements [
	| set |
	set := SLVMOrderedSet new
		add: 2;
		add: 3;
		add: 1;
		yourself.
	self assert: set size equals: 3.
	self assert: set isEmpty not.
	self assert: set isNotEmpty.
	self assert: set first equals: 1.
	self assert: set last equals: 3.
	self assert: set asArray equals: #(1 2 3).
]

{ #category : #tests }
SLVMOrderedSetTest >> testWithTwoElements [
	| set |
	set := SLVMOrderedSet new
		add: 2;
		add: 1;
		yourself.
	self assert: set size equals: 2.
	self assert: set isEmpty not.
	self assert: set isNotEmpty.
	self assert: set first equals: 1.
	self assert: set last equals: 2.
]

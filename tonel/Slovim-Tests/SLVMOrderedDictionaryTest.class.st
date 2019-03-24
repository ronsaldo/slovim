Class {
	#name : #SLVMOrderedDictionaryTest,
	#superclass : #TestCase,
	#category : #'Slovim-Tests'
}

{ #category : #tests }
SLVMOrderedDictionaryTest >> testEmpty [
	| set |
	set := SLVMOrderedDictionary new.
	self assert: set size equals: 0.
	self assert: set isEmpty.
]

{ #category : #tests }
SLVMOrderedDictionaryTest >> testWithOneElement [
	| dict |
	dict := SLVMOrderedDictionary new
		at: 1 put: #a;
		yourself.
	self assert: dict size equals: 1.
	self assert: dict isEmpty not.
	self assert: dict isNotEmpty.
	self assert: dict first equals: 1 -> #a.
	self assert: dict last equals: 1 -> #a.
]

{ #category : #tests }
SLVMOrderedDictionaryTest >> testWithThreeElement [
	| dict |
	dict := SLVMOrderedDictionary new
		at: 2 put: #b;
		at: 3 put: #c;
		at: 1 put: #a;
		yourself.
	self assert: dict size equals: 3.
	self assert: dict isEmpty not.
	self assert: dict isNotEmpty.
	self assert: dict first equals: 1 -> #a.
	self assert: dict last equals: 3 -> #c.
	self assert: dict asArray equals: {
		1 -> #a.
		2 -> #b.
		3 -> #c.
	}.
]

{ #category : #tests }
SLVMOrderedDictionaryTest >> testWithTwoElement [
	| dict |
	dict := SLVMOrderedDictionary new
		at: 2 put: #b;
		at: 1 put: #a;
		yourself.
	self assert: dict size equals: 2.
	self assert: dict isEmpty not.
	self assert: dict isNotEmpty.
	self assert: dict first equals: 1 -> #a.
	self assert: dict last equals: 2 -> #b.
]

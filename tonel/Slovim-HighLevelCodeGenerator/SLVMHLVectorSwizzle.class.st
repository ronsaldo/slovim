Class {
	#name : #SLVMHLVectorSwizzle,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'vector',
		'members'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLVectorSwizzle >> members [
	^ members
]

{ #category : #accessing }
SLVMHLVectorSwizzle >> members: anObject [
	members := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLVectorSwizzle >> translateValueWith: translator [
	^ translator translateHLVectorSwizzleValue: self
]

{ #category : #accessing }
SLVMHLVectorSwizzle >> vector [
	^ vector
]

{ #category : #accessing }
SLVMHLVectorSwizzle >> vector: anObject [
	vector := anObject
]

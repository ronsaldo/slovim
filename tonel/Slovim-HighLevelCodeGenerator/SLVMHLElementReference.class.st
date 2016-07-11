Class {
	#name : #SLVMHLElementReference,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'reference',
		'member',
		'isStructureMember'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLElementReference >> isStructureMember [
	^ isStructureMember
]

{ #category : #accessing }
SLVMHLElementReference >> isStructureMember: anObject [
	isStructureMember := anObject
]

{ #category : #accessing }
SLVMHLElementReference >> member [
	^ member
]

{ #category : #accessing }
SLVMHLElementReference >> member: anObject [
	member := anObject
]

{ #category : #accessing }
SLVMHLElementReference >> reference [
	^ reference
]

{ #category : #accessing }
SLVMHLElementReference >> reference: anObject [
	reference := anObject
]

{ #category : #converting }
SLVMHLElementReference >> translateValueWith: translator [
	^ translator translateHLElementReferenceValue: self
]

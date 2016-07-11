Class {
	#name : #SLVMHLReturnStatement,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'value'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #'as yet unclassified' }
SLVMHLReturnStatement >> translateWith: translator [
	^ translator translateHLReturn: self
]

{ #category : #accessing }
SLVMHLReturnStatement >> value [
	^ value
]

{ #category : #accessing }
SLVMHLReturnStatement >> value: anObject [
	value := anObject
]

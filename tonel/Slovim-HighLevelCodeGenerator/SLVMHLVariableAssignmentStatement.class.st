Class {
	#name : #SLVMHLVariableAssignmentStatement,
	#superclass : #SLVMHLStatement,
	#instVars : [
		'variable',
		'value'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #'as yet unclassified' }
SLVMHLVariableAssignmentStatement >> translateInlineWith: translator [
	^ translator translateHLVariableAssignmentStatementInline: self
]

{ #category : #'as yet unclassified' }
SLVMHLVariableAssignmentStatement >> translateValueWith: translator [
	^ translator translateHLVariableAssignmentStatementValue: self
]

{ #category : #'as yet unclassified' }
SLVMHLVariableAssignmentStatement >> translateWith: translator [
	^ translator translateHLVariableAssignmentStatement: self
]

{ #category : #accessing }
SLVMHLVariableAssignmentStatement >> value [
	^ value
]

{ #category : #accessing }
SLVMHLVariableAssignmentStatement >> value: anObject [
	value := anObject
]

{ #category : #accessing }
SLVMHLVariableAssignmentStatement >> variable [
	^ variable
]

{ #category : #accessing }
SLVMHLVariableAssignmentStatement >> variable: anObject [
	variable := anObject
]

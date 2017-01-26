Class {
	#name : #SLVMHLInternedGlobal,
	#superclass : #SLVMHLCodeNode,
	#instVars : [
		'type',
		'variable',
		'value'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLInternedGlobal >> type [
	^ type
]

{ #category : #accessing }
SLVMHLInternedGlobal >> type: anObject [
	type := anObject
]

{ #category : #accessing }
SLVMHLInternedGlobal >> value [
	^ value
]

{ #category : #accessing }
SLVMHLInternedGlobal >> value: anObject [
	value := anObject
]

{ #category : #accessing }
SLVMHLInternedGlobal >> variable [
	^ variable
]

{ #category : #accessing }
SLVMHLInternedGlobal >> variable: anObject [
	variable := anObject
]

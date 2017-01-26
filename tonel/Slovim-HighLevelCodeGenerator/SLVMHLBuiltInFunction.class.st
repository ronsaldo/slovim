Class {
	#name : #SLVMHLBuiltInFunction,
	#superclass : #SLVMHLCodeNode,
	#instVars : [
		'name',
		'builtin'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLBuiltInFunction >> builtin [
	^ builtin
]

{ #category : #accessing }
SLVMHLBuiltInFunction >> builtin: anObject [
	builtin := anObject
]

{ #category : #accessing }
SLVMHLBuiltInFunction >> internedGlobals [
	^ #()
]

{ #category : #accessing }
SLVMHLBuiltInFunction >> name [
	^ name
]

{ #category : #accessing }
SLVMHLBuiltInFunction >> name: anObject [
	name := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLBuiltInFunction >> translateValueWith: translator [
	^ translator translateHLBuiltInFunctionValue: self
]

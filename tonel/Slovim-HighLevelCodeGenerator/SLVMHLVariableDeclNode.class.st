Class {
	#name : #SLVMHLVariableDeclNode,
	#superclass : #SLVMHLCodeNode,
	#instVars : [
		'isConstant',
		'name',
		'value',
		'type',
		'storage',
		'definition'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLVariableDeclNode >> definition [
	^ definition
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> definition: anObject [
	definition := anObject
]

{ #category : #initialization }
SLVMHLVariableDeclNode >> initialize [
	super initialize.
	isConstant := false.
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> isConstant [
	^ isConstant
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> isConstant: anObject [
	isConstant := anObject
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> name [
	^ name
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> name: anObject [
	name := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLVariableDeclNode >> printOn: aStream [
	aStream nextPutAll: '(global '; print: name; space; print: type name; space; print: value; nextPut: $)
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> storage [
	^ storage
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> storage: anObject [
	storage := anObject
]

{ #category : #'as yet unclassified' }
SLVMHLVariableDeclNode >> translateWith: translator [
	^ translator translateHLVariableDecl: self
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> type [
	^ type
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> type: anObject [
	type := anObject
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> value [
	^ value
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> value: anObject [
	value := anObject
]

Class {
	#name : #SLVMHLVariableDeclNode,
	#superclass : #SLVMHLCodeNode,
	#instVars : [
		'isConstant',
		'name',
		'value',
		'type',
		'storage',
		'definition',
		'needsInternation'
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
	needsInternation := false.
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> isConstant [
	^ isConstant
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> isConstant: anObject [
	isConstant := anObject
]

{ #category : #testing }
SLVMHLVariableDeclNode >> isGlobalVariable [
	^ definition isNotNil and: [ definition isGlobalValue and: [ definition isGlobalVariable ] ]
]

{ #category : #testing }
SLVMHLVariableDeclNode >> isReferenceAsPointer [
	^ type isReferenceType
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> name [
	^ name
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> name: anObject [
	name := anObject
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> needsInternation [
	^ needsInternation
]

{ #category : #accessing }
SLVMHLVariableDeclNode >> needsInternation: anObject [
	needsInternation := anObject
]

{ #category : #printing }
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

{ #category : #converting }
SLVMHLVariableDeclNode >> translateLiteralValueWith: translator [
	^ translator translateHLVariableDeclReference: self
]

{ #category : #converting }
SLVMHLVariableDeclNode >> translateValueWith: translator [
	^ translator translateHLVariableDeclValue: self
]

{ #category : #converting }
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

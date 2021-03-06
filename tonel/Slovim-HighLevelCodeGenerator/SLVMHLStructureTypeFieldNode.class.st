Class {
	#name : #SLVMHLStructureTypeFieldNode,
	#superclass : #SLVMHLCodeNode,
	#instVars : [
		'name',
		'type',
		'binding'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLStructureTypeFieldNode >> binding [
	^ binding
]

{ #category : #accessing }
SLVMHLStructureTypeFieldNode >> binding: anObject [
	binding := anObject
]

{ #category : #accessing }
SLVMHLStructureTypeFieldNode >> name [
	^ name
]

{ #category : #accessing }
SLVMHLStructureTypeFieldNode >> name: anObject [
	name := anObject
]

{ #category : #testing }
SLVMHLStructureTypeFieldNode >> needsInternation [
	^ false
]

{ #category : #'as yet unclassified' }
SLVMHLStructureTypeFieldNode >> printOn: aStream [
	aStream nextPutAll: '(field '; print: name; space; print: type name; nextPut: $).
]

{ #category : #accessing }
SLVMHLStructureTypeFieldNode >> storage [
	^ #structureField
]

{ #category : #accessing }
SLVMHLStructureTypeFieldNode >> type [
	^ type
]

{ #category : #accessing }
SLVMHLStructureTypeFieldNode >> type: anObject [
	type := anObject
]

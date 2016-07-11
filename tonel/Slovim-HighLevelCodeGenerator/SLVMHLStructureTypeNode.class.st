Class {
	#name : #SLVMHLStructureTypeNode,
	#superclass : #SLVMHLTypeNode,
	#instVars : [
		'name',
		'fields',
		'kind'
	],
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #accessing }
SLVMHLStructureTypeNode >> fields [
	^ fields
]

{ #category : #accessing }
SLVMHLStructureTypeNode >> fields: anObject [
	fields := anObject
]

{ #category : #initialization }
SLVMHLStructureTypeNode >> initialize [
	super initialize.
	fields := #().
]

{ #category : #'as yet unclassified' }
SLVMHLStructureTypeNode >> isStructureType [
	^ true
]

{ #category : #accessing }
SLVMHLStructureTypeNode >> kind [
	^ kind
]

{ #category : #accessing }
SLVMHLStructureTypeNode >> kind: anObject [
	kind := anObject
]

{ #category : #accessing }
SLVMHLStructureTypeNode >> name [
	^ name
]

{ #category : #accessing }
SLVMHLStructureTypeNode >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMHLStructureTypeNode >> printOn: aStream [
	aStream nextPutAll: '(structure '; print: name; cr.
	fields do: [ :field |
		aStream print: field; cr.
	].
	aStream nextPut: $)

]

{ #category : #'as yet unclassified' }
SLVMHLStructureTypeNode >> translateWith: translator [
	^ translator translateHLStructure: self
]

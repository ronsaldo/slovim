Class {
	#name : #SLVMPlaceholderType,
	#superclass : #SLVMType,
	#instVars : [
		'name',
		'constraint'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #visitor }
SLVMPlaceholderType >> accept: aVisitor [
	^ aVisitor visitPlaceholderType: self
]

{ #category : #testing }
SLVMPlaceholderType >> canBeExpanded [
	^ constraint canBeExpanded
]

{ #category : #accessing }
SLVMPlaceholderType >> constraint [
	^ constraint
]

{ #category : #accessing }
SLVMPlaceholderType >> constraint: anObject [
	constraint := anObject
]

{ #category : #expansion }
SLVMPlaceholderType >> expand [
	^ constraint expand
]

{ #category : #initialization }
SLVMPlaceholderType >> initialize [
	super initialize.
	constraint := SLVMTypeConstraintAny new.
]

{ #category : #testing }
SLVMPlaceholderType >> isCompliedBy: aType [
	^ constraint isCompliedBy: aType
]

{ #category : #testing }
SLVMPlaceholderType >> isPlaceholderType [
	^ true
]

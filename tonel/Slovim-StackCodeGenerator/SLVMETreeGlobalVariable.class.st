Class {
	#name : #SLVMETreeGlobalVariable,
	#superclass : #SLVMETreeObject,
	#instVars : [
		'name',
		'module',
		'type',
		'valueType',
		'initialValue',
		'binding',
		'debugInformation',
		'debugSourceLocation'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeGlobalVariable >> accept: aVisitor [
	^ aVisitor visitGlobalVariable: self
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> binding [
	^ binding
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> binding: anObject [
	binding := anObject
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> debugInformation [
	^ debugInformation
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> debugInformation: anObject [
	debugInformation := anObject
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> debugSourceLocation [
	^ debugSourceLocation
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> debugSourceLocation: anObject [
	debugSourceLocation := anObject
]

{ #category : #printing }
SLVMETreeGlobalVariable >> fullPrintOn: aStream [
	aStream putIdentifier: self validName; cr.
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> initialValue [
	^ initialValue
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> initialValue: anObject [
	initialValue := anObject
]

{ #category : #testing }
SLVMETreeGlobalVariable >> isGlobalVariable [
	^ true
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> module [
	^ module
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> module: anObject [
	module := anObject
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> name [
	^ name
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMETreeGlobalVariable >> prettyPrintOn: aStream [
	aStream putIdentifier: self validName
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> type [
	^ type
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> type: anObject [
	type := anObject
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> validName [
	^ name ifNil: [ #anonymous ]
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> valueType [
	^ valueType
]

{ #category : #accessing }
SLVMETreeGlobalVariable >> valueType: anObject [
	valueType := anObject
]

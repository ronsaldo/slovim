Class {
	#name : #SLVMETreeFunction,
	#superclass : #SLVMETreeObject,
	#instVars : [
		'name',
		'arguments',
		'basicBlocks',
		'debugInformation',
		'debugSourceLocation'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeFunction >> accept: aVisitor [
	^ aVisitor visitFunction: self
]

{ #category : #adding }
SLVMETreeFunction >> addArgument: anArgument [
	arguments add: anArgument
]

{ #category : #adding }
SLVMETreeFunction >> addBasicBlock: aBasicBlock [
	basicBlocks add: aBasicBlock.
	aBasicBlock index: basicBlocks size
]

{ #category : #accessing }
SLVMETreeFunction >> arguments [
	^ arguments
]

{ #category : #accessing }
SLVMETreeFunction >> basicBlocks [
	^ basicBlocks
]

{ #category : #accessing }
SLVMETreeFunction >> debugInformation [
	^ debugInformation
]

{ #category : #accessing }
SLVMETreeFunction >> debugInformation: anObject [
	debugInformation := anObject
]

{ #category : #accessing }
SLVMETreeFunction >> debugSourceLocation [
	^ debugSourceLocation
]

{ #category : #accessing }
SLVMETreeFunction >> debugSourceLocation: anObject [
	debugSourceLocation := anObject
]

{ #category : #printing }
SLVMETreeFunction >> fullPrintOn: aStream [
	aStream putIdentifier: self validName; cr;
		nextPutAll: '{'; cr.
		
	basicBlocks do: [ :bb | bb fullPrintOn: aStream ].
	
	aStream 
		nextPutAll: '}'; cr.

]

{ #category : #printing }
SLVMETreeFunction >> fullPrintString [
	^ SLVMPrintingStream fullPrintString: self
]

{ #category : #printing }
SLVMETreeFunction >> fullPrintText [
	^ SLVMPrintingTextStream fullPrintString: self
]

{ #category : #initialization }
SLVMETreeFunction >> initialize [
	super initialize.
	arguments := OrderedCollection new.
	basicBlocks := OrderedCollection new.
	
]

{ #category : #accessing }
SLVMETreeFunction >> name [
	^ name
]

{ #category : #accessing }
SLVMETreeFunction >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMETreeFunction >> prettyPrintOn: aStream [
	aStream putIdentifier: self validName
]

{ #category : #printing }
SLVMETreeFunction >> printOn: aStream [
	aStream nextPutAll: self validName
]

{ #category : #accessing }
SLVMETreeFunction >> validName [
	^ name ifNil: [ #anonymous ]
]

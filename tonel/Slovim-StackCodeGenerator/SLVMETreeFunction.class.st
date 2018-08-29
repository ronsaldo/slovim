Class {
	#name : #SLVMETreeFunction,
	#superclass : #SLVMETreeObject,
	#instVars : [
		'name',
		'module',
		'arguments',
		'basicBlocks',
		'debugInformation',
		'debugSourceLocation',
		'selector',
		'classBinding'
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
SLVMETreeFunction >> classBinding [
	^ classBinding
]

{ #category : #accessing }
SLVMETreeFunction >> classBinding: anObject [
	classBinding := anObject
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

{ #category : #'gt-inspector-extension' }
SLVMETreeFunction >> gtInspectorModuleText: composite [
	<gtInspectorPresentationOrder: 1>
	^ (composite text)
		title: 'Assembly Module';
		format: #fullPrintText
]

{ #category : #initialization }
SLVMETreeFunction >> initialize [
	super initialize.
	arguments := OrderedCollection new.
	basicBlocks := OrderedCollection new.
	
]

{ #category : #testing }
SLVMETreeFunction >> isETreeFunction [
	^ true
]

{ #category : #testing }
SLVMETreeFunction >> isETreeMethod [
	^ arguments isNotEmpty and: [ arguments first isReceiver ]
]

{ #category : #testing }
SLVMETreeFunction >> isPureExpression [
	^ true
]

{ #category : #accessing }
SLVMETreeFunction >> module [
	^ module
]

{ #category : #accessing }
SLVMETreeFunction >> module: anObject [
	module := anObject
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
SLVMETreeFunction >> selector [
	^ selector
]

{ #category : #accessing }
SLVMETreeFunction >> selector: anObject [
	self assert: anObject isSymbol.
	selector := anObject
]

{ #category : #accessing }
SLVMETreeFunction >> validName [
	^ name ifNil: [ #anonymous ]
]

Class {
	#name : #SLVMETreeFunctionArgument,
	#superclass : #SLVMETreeValue,
	#instVars : [
		'name',
		'flags'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeFunctionArgument >> accept: aVisitor [
	^ aVisitor visitFunctionArgument: self
]

{ #category : #accessing }
SLVMETreeFunctionArgument >> flags [
	^ flags
]

{ #category : #accessing }
SLVMETreeFunctionArgument >> flags: anObject [
	flags := anObject
]

{ #category : #testing }
SLVMETreeFunctionArgument >> hasFlag: aFlag [
	^ flags includes: aFlag
]

{ #category : #testing }
SLVMETreeFunctionArgument >> isReceiver [
	^ self hasFlag: #receiver
]

{ #category : #accessing }
SLVMETreeFunctionArgument >> name [
	^ name
]

{ #category : #accessing }
SLVMETreeFunctionArgument >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMETreeFunctionArgument >> prettyPrintOn: aStream [
	aStream nextPutAll: '('; putKeyword: #arg; space; putIdentifier: self validName; nextPutAll: ')'
]

{ #category : #accessing }
SLVMETreeFunctionArgument >> validName [
	^ name ifNil: [#anonArg]
]

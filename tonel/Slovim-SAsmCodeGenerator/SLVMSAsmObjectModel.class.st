Class {
	#name : #SLVMSAsmObjectModel,
	#superclass : #Object,
	#instVars : [
		'target',
		'objectModel',
		'widowThisContextFunction'
	],
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #accessing }
SLVMSAsmObjectModel >> importFunction: slvmFunction [
	^ (target cFunctionPrefix , slvmFunction name) asSymbol
]

{ #category : #accessing }
SLVMSAsmObjectModel >> objectModel [
	^ objectModel
]

{ #category : #accessing }
SLVMSAsmObjectModel >> objectModel: anObject [
	objectModel := anObject
]

{ #category : #accessing }
SLVMSAsmObjectModel >> target [
	^ target
]

{ #category : #accessing }
SLVMSAsmObjectModel >> target: anObject [
	target := anObject
]

{ #category : #accessing }
SLVMSAsmObjectModel >> widowThisContextFunction [
	^ widowThisContextFunction ifNil: [widowThisContextFunction := self importFunction: objectModel widowThisContextFunction]
]

"
I represent a node in an intermediate representation for a high-level language code.
"
Class {
	#name : #SLVMHLCodeNode,
	#superclass : #Object,
	#category : #'Slovim-HighLevelCodeGenerator'
}

{ #category : #testing }
SLVMHLCodeNode >> isArrayType [
	^ false
]

{ #category : #testing }
SLVMHLCodeNode >> isCodeNode [
	^ true
]

{ #category : #testing }
SLVMHLCodeNode >> isContinue [
	^ false
]

{ #category : #testing }
SLVMHLCodeNode >> isGlobalVariable [
	^ false
]

{ #category : #testing }
SLVMHLCodeNode >> isIfStatement [
	^ false
]

{ #category : #testing }
SLVMHLCodeNode >> isReferenceAsPointer [
	^ false
]

{ #category : #testing }
SLVMHLCodeNode >> isReturnVoid [
	^ false
]

{ #category : #testing }
SLVMHLCodeNode >> isStatement [
	^ false
]

{ #category : #testing }
SLVMHLCodeNode >> isStructureType [
	^ false
]

{ #category : #converting }
SLVMHLCodeNode >> translateInlineWith: translator [
	self subclassResponsibility
]

{ #category : #converting }
SLVMHLCodeNode >> translateLiteralValueWith: translator [
	^ self translateValueWith: translator
]

{ #category : #converting }
SLVMHLCodeNode >> translateValueWith: translator [
	self subclassResponsibility
]

{ #category : #converting }
SLVMHLCodeNode >> translateWith: translator [
	self subclassResponsibility
]

Class {
	#name : #SLVMETreeStoreExpression,
	#superclass : #SLVMETreeExpression,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeStoreExpression >> accept: aVisitor [
	^ aVisitor visitStore: self
]

{ #category : #testing }
SLVMETreeStoreExpression >> isStore [
	^ true
]

{ #category : #accessing }
SLVMETreeStoreExpression >> name [
	^ #store
]

{ #category : #evaluating }
SLVMETreeStoreExpression >> value [
	^ parameters first
]

{ #category : #evaluating }
SLVMETreeStoreExpression >> variable [
	^ parameters second
]

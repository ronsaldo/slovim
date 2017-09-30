Class {
	#name : #SLVMETreeVisitor,
	#superclass : #Object,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeVisitor >> visitAlloca: instruction [
	self subclassResponsibility
]

{ #category : #visiting }
SLVMETreeVisitor >> visitBinaryExpression: instruction [
	self subclassResponsibility
]

{ #category : #visiting }
SLVMETreeVisitor >> visitBranch: instruction [
	self subclassResponsibility
]

{ #category : #visiting }
SLVMETreeVisitor >> visitCall: instruction [
	self subclassResponsibility
]

{ #category : #visiting }
SLVMETreeVisitor >> visitETreeStatement: anStatement [
	self subclassResponsibility
]

{ #category : #visiting }
SLVMETreeVisitor >> visitJump: instruction [
	self subclassResponsibility
]

{ #category : #visiting }
SLVMETreeVisitor >> visitLoad: instruction [
	self subclassResponsibility
]

{ #category : #visiting }
SLVMETreeVisitor >> visitReturn: instruction [
	self subclassResponsibility
]

{ #category : #visiting }
SLVMETreeVisitor >> visitReturnVoid: instruction [
	self subclassResponsibility
]

{ #category : #visiting }
SLVMETreeVisitor >> visitStore: instruction [
	self subclassResponsibility
]

{ #category : #visiting }
SLVMETreeVisitor >> visitUnaryExpression: instruction [
	self subclassResponsibility
]

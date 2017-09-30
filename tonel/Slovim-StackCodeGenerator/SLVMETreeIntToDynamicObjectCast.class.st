Class {
	#name : #SLVMETreeIntToDynamicObjectCast,
	#superclass : #SLVMETreeDynamicObjectNativeCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #accessing }
SLVMETreeIntToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitIntToDynamicObjectCast: self
]

{ #category : #accessing }
SLVMETreeIntToDynamicObjectCast >> name [
	^ #int2dynobject
]

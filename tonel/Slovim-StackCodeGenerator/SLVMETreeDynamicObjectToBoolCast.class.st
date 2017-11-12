Class {
	#name : #SLVMETreeDynamicObjectToBoolCast,
	#superclass : #SLVMETreeDynamicObjectToNativeCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeDynamicObjectToBoolCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToBoolCast: self
]

{ #category : #accessing }
SLVMETreeDynamicObjectToBoolCast >> name [
	^ #dynobject2bool
]

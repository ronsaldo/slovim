Class {
	#name : #SLVMETreeDynamicObjectToIntCast,
	#superclass : #SLVMETreeDynamicObjectToNativeCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #accessing }
SLVMETreeDynamicObjectToIntCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToIntCast: self
]

{ #category : #accessing }
SLVMETreeDynamicObjectToIntCast >> name [
	^ #dynobject2int
]

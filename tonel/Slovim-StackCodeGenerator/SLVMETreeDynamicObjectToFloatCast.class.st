Class {
	#name : #SLVMETreeDynamicObjectToFloatCast,
	#superclass : #SLVMETreeDynamicObjectToNativeCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #accessing }
SLVMETreeDynamicObjectToFloatCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToFloatCast: self
]

{ #category : #accessing }
SLVMETreeDynamicObjectToFloatCast >> name [
	^ #dynobject2float
]

Class {
	#name : #SLVMETreeDynamicObjectToFloatCast,
	#superclass : #SLVMETreeDynamicObjectNativeCast,
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

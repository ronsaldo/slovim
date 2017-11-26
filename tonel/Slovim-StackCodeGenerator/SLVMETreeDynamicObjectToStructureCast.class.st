Class {
	#name : #SLVMETreeDynamicObjectToStructureCast,
	#superclass : #SLVMETreeDynamicObjectCompositeCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeDynamicObjectToStructureCast >> accept: aVisitor [
	^ aVisitor visitDynamicObjectToStructureCast: self
]

{ #category : #visiting }
SLVMETreeDynamicObjectToStructureCast >> name [
	^ #dynobject2struct
]

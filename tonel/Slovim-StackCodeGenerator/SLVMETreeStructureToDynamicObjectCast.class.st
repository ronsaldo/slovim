Class {
	#name : #SLVMETreeStructureToDynamicObjectCast,
	#superclass : #SLVMETreeDynamicObjectCompositeCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeStructureToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitStructureToDynamicObjectCast: self
]

{ #category : #accessing }
SLVMETreeStructureToDynamicObjectCast >> name [
	^ #struct2dynobject
]

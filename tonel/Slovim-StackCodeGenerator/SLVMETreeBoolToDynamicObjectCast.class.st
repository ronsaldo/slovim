Class {
	#name : #SLVMETreeBoolToDynamicObjectCast,
	#superclass : #SLVMETreeNativeToDynamicObjectCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeBoolToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitBoolToDynamicObjectCast: self
]

{ #category : #accessing }
SLVMETreeBoolToDynamicObjectCast >> name [
	^ #bool2dynobject
]

Class {
	#name : #SLVMETreeFloatToDynamicObjectCast,
	#superclass : #SLVMETreeNativeToDynamicObjectCast,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #accessing }
SLVMETreeFloatToDynamicObjectCast >> accept: aVisitor [
	^ aVisitor visitFloatToDynamicObjectCast: self
]

{ #category : #accessing }
SLVMETreeFloatToDynamicObjectCast >> name [
	^ #float2dynobject
]

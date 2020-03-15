Class {
	#name : #SLVMNativeToDynamicObjectCast,
	#superclass : #SLVMDynamicObjectNativeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #testing }
SLVMNativeToDynamicObjectCast class >> isAbstract [
	^ self == SLVMNativeToDynamicObjectCast
]

Class {
	#name : #SLVMDynamicObjectToNativeCast,
	#superclass : #SLVMDynamicObjectNativeCast,
	#category : #'Slovim-Core-SSA'
}

{ #category : #testing }
SLVMDynamicObjectToNativeCast class >> isAbstract [
	^ self == SLVMDynamicObjectToNativeCast
]

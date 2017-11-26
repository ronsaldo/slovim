Class {
	#name : #SLVMETreeDynamicObjectCompositeCast,
	#superclass : #SLVMETreeCast,
	#instVars : [
		'typeObject'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #accessing }
SLVMETreeDynamicObjectCompositeCast >> typeObject [
	^ parameters second
]

Class {
	#name : #SLVMSampleInstruction,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #accessing }
SLVMSampleInstruction >> sampledTexture [
	^ parameters first
]

{ #category : #accessing }
SLVMSampleInstruction >> texcoord [
	^ parameters second
]

{ #category : #accessing }
SLVMSampleInstruction >> type [
	^ type
]

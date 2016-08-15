Class {
	#name : #SLVMLirX86LocalPointer,
	#superclass : #SLVMLirInstructionOperand,
	#instVars : [
		'local',
		'size'
	],
	#classVars : [
		'ScaleValueMap'
	],
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #accessing }
SLVMLirX86LocalPointer >> local [
	^ local
]

{ #category : #accessing }
SLVMLirX86LocalPointer >> local: anObject [
	local := anObject
]

{ #category : #accessing }
SLVMLirX86LocalPointer >> size [
	^ size
]

{ #category : #accessing }
SLVMLirX86LocalPointer >> size: anObject [
	size := anObject
]

Class {
	#name : #SLVMLirBinaryFileComponent,
	#superclass : #Object,
	#instVars : [
		'fileOffset'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #accessing }
SLVMLirBinaryFileComponent >> fileOffset [
	^ fileOffset
]

{ #category : #accessing }
SLVMLirBinaryFileComponent >> fileOffset: anObject [
	fileOffset := anObject
]

Class {
	#name : #SLVMLirBinaryFileComponent,
	#superclass : #Object,
	#instVars : [
		'fileOffset'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #accessing }
SLVMLirBinaryFileComponent >> alignment [
	^ 1
]

{ #category : #accessing }
SLVMLirBinaryFileComponent >> fileOffset [
	^ fileOffset
]

{ #category : #accessing }
SLVMLirBinaryFileComponent >> fileOffset: anObject [
	fileOffset := anObject
]

{ #category : #writing }
SLVMLirBinaryFileComponent >> prepareForWritingToFile [
	"Do nothing for now"
]

{ #category : #accessing }
SLVMLirBinaryFileComponent >> size [
	self subclassResponsibility.
]

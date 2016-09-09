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
SLVMLirBinaryFileComponent >> prepareForWritingToFile: baseAddress [
	"Do nothing for now"
	^ baseAddress
]

{ #category : #accessing }
SLVMLirBinaryFileComponent >> size [
	self subclassResponsibility.
]

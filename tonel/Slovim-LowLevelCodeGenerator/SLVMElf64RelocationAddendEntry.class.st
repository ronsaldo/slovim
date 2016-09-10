Class {
	#name : #SLVMElf64RelocationAddendEntry,
	#superclass : #SLVMElf64RelocationEntry,
	#instVars : [
		'addend'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #'as yet unclassified' }
SLVMElf64RelocationAddendEntry class >> entrySize [
	^ 24
]

{ #category : #accessing }
SLVMElf64RelocationAddendEntry >> addend [
	^ addend
]

{ #category : #accessing }
SLVMElf64RelocationAddendEntry >> addend: anObject [
	addend := anObject
]

{ #category : #'as yet unclassified' }
SLVMElf64RelocationAddendEntry >> writeOn: aStream [
	aStream
		nextPutInt64: offset;
		nextPutInt64: info;
		nextPutInt64: addend
]

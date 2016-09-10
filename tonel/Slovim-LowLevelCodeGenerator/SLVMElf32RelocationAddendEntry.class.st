Class {
	#name : #SLVMElf32RelocationAddendEntry,
	#superclass : #SLVMElf32RelocationEntry,
	#instVars : [
		'addend'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #'as yet unclassified' }
SLVMElf32RelocationAddendEntry class >> entrySize [
	^ 12
]

{ #category : #accessing }
SLVMElf32RelocationAddendEntry >> addend [
	^ addend
]

{ #category : #accessing }
SLVMElf32RelocationAddendEntry >> addend: anObject [
	addend := anObject
]

{ #category : #'as yet unclassified' }
SLVMElf32RelocationAddendEntry >> writeOn: aStream [
	aStream
		nextPutInt32: offset;
		nextPutInt32: info;
		nextPutInt32: addend
]

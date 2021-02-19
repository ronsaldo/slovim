Class {
	#name : #LLVMDIFile,
	#superclass : #LLVMDIScope,
	#instVars : [
		'filename',
		'directory',
		'checksumkind',
		'checksum'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDIFile >> checksum [
	^ checksum
]

{ #category : #accessing }
LLVMDIFile >> checksum: anObject [
	checksum := anObject
]

{ #category : #accessing }
LLVMDIFile >> checksumkind [
	^ checksumkind
]

{ #category : #accessing }
LLVMDIFile >> checksumkind: anObject [
	checksumkind := anObject
]

{ #category : #accessing }
LLVMDIFile >> directory [
	^ directory
]

{ #category : #accessing }
LLVMDIFile >> directory: anObject [
	directory := anObject
]

{ #category : #'as yet unclassified' }
LLVMDIFile >> doConcretizeWithDIBuilder: builder [
	handle := builder createFile: filename len: filename size directory: directory directoryLen: directory size
]

{ #category : #accessing }
LLVMDIFile >> filename [
	^ filename
]

{ #category : #accessing }
LLVMDIFile >> filename: anObject [
	filename := anObject
]

{ #category : #accessing }
LLVMDIFile >> specializedName [
	^ #DIFile
]

{ #category : #accessing }
LLVMDIFile >> specializedProperties [
	^ #(filename directory checksumkind checksum)
]

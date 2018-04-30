Class {
	#name : #LLVMDIFile,
	#superclass : #LLVMDIScope,
	#instVars : [
		'filename',
		'directory'
	],
	#category : #'LLVM-IR-Metadata'
}

{ #category : #accessing }
LLVMDIFile >> directory [
	^ directory
]

{ #category : #accessing }
LLVMDIFile >> directory: anObject [
	directory := anObject
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
	^ #(filename directory)
]

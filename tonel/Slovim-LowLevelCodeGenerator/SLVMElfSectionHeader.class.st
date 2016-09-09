Class {
	#name : #SLVMElfSectionHeader,
	#superclass : #SLVMLirBinaryFileComponent,
	#instVars : [
		'content',
		'index'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #accessing }
SLVMElfSectionHeader >> content [
	^ content
]

{ #category : #accessing }
SLVMElfSectionHeader >> content: anObject [
	content := anObject
]

{ #category : #accessing }
SLVMElfSectionHeader >> index [
	^ index
]

{ #category : #accessing }
SLVMElfSectionHeader >> index: anObject [
	index := anObject
]

{ #category : #'as yet unclassified' }
SLVMElfSectionHeader >> prepareForWritingToFile: baseAddress [
	content ifNil: [ ^ baseAddress ].
	
	self offset: content fileOffset.
	self contentSize: content size.
	self isAllocated ifFalse: [
		^ baseAddress 
	].

	self address: (baseAddress alignedTo: content alignment).
	^ self address + self size

]

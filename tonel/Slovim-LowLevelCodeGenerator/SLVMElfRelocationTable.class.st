Class {
	#name : #SLVMElfRelocationTable,
	#superclass : #SLVMLirBinaryFileComponent,
	#instVars : [
		'entries'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #initialization }
SLVMElfRelocationTable >> initialize [
	super initialize.
	entries := OrderedCollection new.
]

{ #category : #initialization }
SLVMElfRelocationTable >> newEntry [
	^ entries add: self relocationEntryClass new
]

{ #category : #factory }
SLVMElfRelocationTable >> relocationEntryClass [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMElfRelocationTable >> size [
	^ self relocationEntryClass entrySize * entries size
]

{ #category : #writing }
SLVMElfRelocationTable >> writeOn: aStream [
	entries do: [ :entry | entry writeOn: aStream ]
]

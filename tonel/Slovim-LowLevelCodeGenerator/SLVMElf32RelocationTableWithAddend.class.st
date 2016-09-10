Class {
	#name : #SLVMElf32RelocationTableWithAddend,
	#superclass : #SLVMElfRelocationTable,
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #factory }
SLVMElf32RelocationTableWithAddend >> relocationEntryClass [
	^ SLVMElf32RelocationAddendEntry
]

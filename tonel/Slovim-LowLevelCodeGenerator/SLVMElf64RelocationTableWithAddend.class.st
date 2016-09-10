Class {
	#name : #SLVMElf64RelocationTableWithAddend,
	#superclass : #SLVMElfRelocationTable,
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #factory }
SLVMElf64RelocationTableWithAddend >> relocationEntryClass [
	^ SLVMElf64RelocationAddendEntry
]

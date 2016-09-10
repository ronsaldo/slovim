Class {
	#name : #SLVMElf32RelocationTable,
	#superclass : #SLVMElfRelocationTable,
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #factory }
SLVMElf32RelocationTable >> relocationEntryClass [
	^ SLVMElf32RelocationEntry
]

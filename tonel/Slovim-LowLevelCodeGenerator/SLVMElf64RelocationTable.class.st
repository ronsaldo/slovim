Class {
	#name : #SLVMElf64RelocationTable,
	#superclass : #SLVMElfRelocationTable,
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #factory }
SLVMElf64RelocationTable >> relocationEntryClass [
	^ SLVMElf64RelocationEntry
]

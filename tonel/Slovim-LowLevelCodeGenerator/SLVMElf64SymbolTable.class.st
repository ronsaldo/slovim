Class {
	#name : #SLVMElf64SymbolTable,
	#superclass : #SLVMElf32SymbolTable,
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #factory }
SLVMElf64SymbolTable >> symbolEntryClass [
	^ SLVMElf64SymbolTableEntry
]

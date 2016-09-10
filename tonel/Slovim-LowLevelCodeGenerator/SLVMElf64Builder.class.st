Class {
	#name : #SLVMElf64Builder,
	#superclass : #SLVMElfBuilder,
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #'format classes' }
SLVMElf64Builder >> headerClass [
	^ SLVMElf64Header
]

{ #category : #'as yet unclassified' }
SLVMElf64Builder >> pointerAlignment [
	^ 8
]

{ #category : #'format classes' }
SLVMElf64Builder >> programHeaderClass [
	^ SLVMElf64ProgramHeader
]

{ #category : #'format classes' }
SLVMElf64Builder >> relocationTableClass [
	^ SLVMElf64RelocationTable
]

{ #category : #'format classes' }
SLVMElf64Builder >> relocationWithAddendTableClass [
	^ SLVMElf64RelocationTableWithAddend
]

{ #category : #'format classes' }
SLVMElf64Builder >> sectionHeaderClass [
	^ SLVMElf64SectionHeader
]

{ #category : #'format classes' }
SLVMElf64Builder >> stringTableClass [
	^ SLVMElfStringTable
]

{ #category : #'format classes' }
SLVMElf64Builder >> symbolTableClass [
	^ SLVMElf64SymbolTable
]

{ #category : #'format classes' }
SLVMElf64Builder >> symbolTableEntryClass [
	^ SLVMElf64SymbolTableEntry
]

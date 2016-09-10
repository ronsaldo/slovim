Class {
	#name : #SLVMElf32Builder,
	#superclass : #SLVMElfBuilder,
	#category : #'Slovim-LowLevelCodeGenerator-Elf'
}

{ #category : #'format classes' }
SLVMElf32Builder >> headerClass [
	^ SLVMElf32Header
]

{ #category : #accessing }
SLVMElf32Builder >> pointerAlignment [
	^ 4
]

{ #category : #'format classes' }
SLVMElf32Builder >> programHeaderClass [
	^ SLVMElf32ProgramHeader
]

{ #category : #'format classes' }
SLVMElf32Builder >> relocationTableClass [
	^ SLVMElf32RelocationTable
]

{ #category : #'format classes' }
SLVMElf32Builder >> relocationWithAddendTableClass [
	^ SLVMElf32RelocationTableWithAddend
]

{ #category : #'format classes' }
SLVMElf32Builder >> sectionHeaderClass [
	^ SLVMElf32SectionHeader
]

{ #category : #'format classes' }
SLVMElf32Builder >> stringTableClass [
	^ SLVMElfStringTable
]

{ #category : #'format classes' }
SLVMElf32Builder >> symbolTableClass [
	^ SLVMElf32SymbolTable
]

{ #category : #'format classes' }
SLVMElf32Builder >> symbolTableEntryClass [
	^ SLVMElf32SymbolTableEntry
]

Class {
	#name : #SLVMPackedStructureLayout,
	#superclass : #SLVMStructureLayout,
	#category : #'Slovim-Runtime-Slots'
}

{ #category : #'instance creation' }
SLVMPackedStructureLayout class >> extending: superLayout scope: aScope host: aClass [
	^ (superLayout extendSLVMPackedStructure: aScope)
		host: aClass;
		yourself
]

{ #category : #private }
SLVMPackedStructureLayout >> computeLayout [
	structureSize := 0.
	structureAlignment := 1.
	
	self allSlotsDo: [ :slot |
		slot offset: structureSize.
		structureSize := structureSize + slot fieldSize.
	].

]

{ #category : #extending }
SLVMPackedStructureLayout >> extendSLVMPackedStructure: aScope [
	^ self species new slotScope: aScope
]

{ #category : #extending }
SLVMPackedStructureLayout >> extendSLVMStructure: aScope [
	IncompatibleLayoutConflict new
		layout: self;
		subType: #structure;
		signal
]

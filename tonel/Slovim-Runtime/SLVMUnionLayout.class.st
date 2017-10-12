Class {
	#name : #SLVMUnionLayout,
	#superclass : #SLVMStructureLayout,
	#category : #'Slovim-Runtime-Slots'
}

{ #category : #'instance creation' }
SLVMUnionLayout class >> extending: superLayout scope: aScope host: aClass [
	^ (superLayout extendSLVMUnion: aScope)
		host: aClass;
		yourself
]

{ #category : #private }
SLVMUnionLayout >> computeLayout [
	structureSize := 0.
	structureAlignment := 1.
	
	self allSlotsDo: [ :slot |
		slot offset: 0.
		structureAlignment := structureAlignment max: slot alignment.
		structureSize := structureSize max: slot fieldSize.
	].

	structureSize := structureSize alignedTo: structureAlignment

]

{ #category : #extending }
SLVMUnionLayout >> extendSLVMStructure: aScope [
	IncompatibleLayoutConflict new
		layout: self;
		subType: #structure;
		signal
]

{ #category : #extending }
SLVMUnionLayout >> extendSLVMUnion: aScope [
	^ self species new slotScope: aScope
]

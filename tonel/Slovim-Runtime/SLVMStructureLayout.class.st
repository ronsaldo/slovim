Class {
	#name : #SLVMStructureLayout,
	#superclass : #PointerLayout,
	#instVars : [
		'structureSize',
		'structureAlignment'
	],
	#category : #'Slovim-Runtime-Slots'
}

{ #category : #'instance creation' }
SLVMStructureLayout class >> extending: superLayout scope: aScope host: aClass [
	^ (superLayout extendSLVMStructure: aScope)
		host: aClass;
		yourself
]

{ #category : #private }
SLVMStructureLayout >> computeLayout [
	structureSize := 0.
	structureAlignment := 1.
	
	self allSlotsDo: [ :slot |
		slot offset: (structureSize alignedTo: slot alignment).
		structureAlignment := structureAlignment max: slot alignment.
		structureSize := structureSize + slot fieldSize.
	].

	structureSize := structureSize alignedTo: structureAlignment

]

{ #category : #extending }
SLVMStructureLayout >> extend [
	^ self extendSLVMStructure: self slotScope extend
]

{ #category : #extending }
SLVMStructureLayout >> extend: aScope [
	IncompatibleLayoutConflict new
		layout: self;
		subType: #pointers;
		signal
]

{ #category : #extending }
SLVMStructureLayout >> extendSLVMPackedStructure: aScope [
	IncompatibleLayoutConflict new
		layout: self;
		subType: #packedStructure;
		signal
]

{ #category : #extending }
SLVMStructureLayout >> extendSLVMStructure: aScope [
	^ self species new slotScope: aScope
]

{ #category : #extending }
SLVMStructureLayout >> extendSLVMUnion: aScope [
	IncompatibleLayoutConflict new
		layout: self;
		subType: #union;
		signal
]

{ #category : #extending }
SLVMStructureLayout >> extendWeak: aScope [
	IncompatibleLayoutConflict new
		layout: self;
		subType: #weak;
		signal
]

{ #category : #accessing }
SLVMStructureLayout >> fieldSize [
	^ 0
]

{ #category : #accessing }
SLVMStructureLayout >> instVarNames [
	^ slotScope visibleSlotNames
]

{ #category : #accessing }
SLVMStructureLayout >> instanceSpecification [
	"Bytes"
	^ 16
]

{ #category : #testing }
SLVMStructureLayout >> isCustomLayout [
	^ true
]

{ #category : #accessing }
SLVMStructureLayout >> minimalAlignment: anAlignment [
	structureAlignment := structureAlignment max: anAlignment.
	structureSize := structureSize alignedTo: structureAlignment.
]

{ #category : #accessing }
SLVMStructureLayout >> size [
	^ 0
]

{ #category : #accessing }
SLVMStructureLayout >> slotScope: aSlotScope [
	super slotScope: aSlotScope.
	self computeLayout
]

{ #category : #accessing }
SLVMStructureLayout >> structureAlignment [
	^ structureAlignment
]

{ #category : #accessing }
SLVMStructureLayout >> structureSize [
	^ structureSize
]

Class {
	#name : #SLVMInternalStructure,
	#superclass : #Object,
	#category : #'Slovim-Runtime-Slots'
}

{ #category : #'instance creation' }
SLVMInternalStructure class >> basicNew [
	^ self basicNew: self structureSize
]

{ #category : #'instance creation' }
SLVMInternalStructure class >> basicNew: aVariableSize [
	^ super basicNew: self structureSize + aVariableSize
]

{ #category : #accessing }
SLVMInternalStructure class >> structureAlignment [
	^ layout structureAlignment
]

{ #category : #accessing }
SLVMInternalStructure class >> structureSize [
	^ layout structureSize
]

{ #category : #'gt-inspector' }
SLVMInternalStructure >> gtInspectorVariableNodesIn: aCollection [
	"Only show the slots. Do not show the raw data."
	
	aCollection
		addAll: ((self class allSlots collect: [ :slot | 
			GTInspectorSlotNode hostObject: self slot: slot ]))
]

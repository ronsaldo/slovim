Class {
	#name : #SLVMRegisterAllocator,
	#superclass : #Object,
	#instVars : [
		'function',
		'lirFunction',
		'allocatableRegisterClasses'
	],
	#category : #'Slovim-LowLevelCodeGenerator-RegisterAllocation'
}

{ #category : #'as yet unclassified' }
SLVMRegisterAllocator >> allocateRegisters [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SLVMRegisterAllocator >> buildAllocatableRegisterClasses: allocatableRegisters [
	| registers |
	allocatableRegisterClasses := OrderedDictionary new.
	allocatableRegisters do: [ :reg |
		registers := allocatableRegisterClasses at: reg class ifAbsentPut: [ OrderedCollection new ].
		registers add: reg
	]
]

{ #category : #'as yet unclassified' }
SLVMRegisterAllocator >> findRegisterClassForValue: value [
	allocatableRegisterClasses keysAndValuesDo: [ :key :values|
		(key canHoldValueOfType: value type forTarget: lirFunction compilationTarget ) ifTrue: [ ^values ]
	].
	^ nil
]

{ #category : #accessing }
SLVMRegisterAllocator >> function [
	^ function
]

{ #category : #accessing }
SLVMRegisterAllocator >> function: anObject [
	function := anObject
]

{ #category : #accessing }
SLVMRegisterAllocator >> lirFunction [
	^ lirFunction
]

{ #category : #accessing }
SLVMRegisterAllocator >> lirFunction: anObject [
	lirFunction := anObject
]

{ #category : #'as yet unclassified' }
SLVMRegisterAllocator >> mapSSA: value toSpillLocation: local [
	lirFunction mapSSA: value toStackVariable: local
]

{ #category : #'as yet unclassified' }
SLVMRegisterAllocator >> translateBasicBlock: bb with: translator [
	translator translateBasicBlock: bb
]

{ #category : #'as yet unclassified' }
SLVMRegisterAllocator >> translateBasicBlocks: basicBlocks with: translator [
	basicBlocks do: [ :bb |
		self translateBasicBlock: bb with: translator
	]
]

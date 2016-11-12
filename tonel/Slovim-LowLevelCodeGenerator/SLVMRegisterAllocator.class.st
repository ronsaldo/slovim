Class {
	#name : #SLVMRegisterAllocator,
	#superclass : #Object,
	#instVars : [
		'function',
		'lirFunction',
		'callingConvention',
		'allocatableRegisterClasses',
		'scratchRegisterClasses',
		'callingConventionDescriptionDictionary',
		'usedRegisters'
	],
	#category : #'Slovim-LowLevelCodeGenerator-RegisterAllocation'
}

{ #category : #'as yet unclassified' }
SLVMRegisterAllocator class >> default [
	^ SLVMLinearScanRegisterAllocator new
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> allocateInstructionResultRegister: instruction [
	^ (self findScratchRegisterClassElementsForValue: instruction) first
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> allocateRegisters [
	self subclassResponsibility
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> buildAllocatableRegisterClasses: allocatableRegisters [
	| registers |
	allocatableRegisterClasses := OrderedDictionary new.
	allocatableRegisters do: [ :reg |
		registers := allocatableRegisterClasses at: reg class ifAbsentPut: [ OrderedCollection new ].
		registers add: reg
	]
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> buildScratchRegisterClasses: scratchRegisters [
	| registers |
	scratchRegisterClasses := OrderedDictionary new.
	scratchRegisters do: [ :reg |
		registers := scratchRegisterClasses at: reg class ifAbsentPut: [ OrderedCollection new ].
		registers add: reg
	]
]

{ #category : #accessing }
SLVMRegisterAllocator >> callerRegistersToPreserve [
	^ callingConvention callerRegisters
]

{ #category : #accessing }
SLVMRegisterAllocator >> callingConvention [
	^ callingConvention
]

{ #category : #accessing }
SLVMRegisterAllocator >> callingConvention: anObject [
	callingConvention := anObject
]

{ #category : #accessing }
SLVMRegisterAllocator >> callingConventionDescriptionNamed: conventionName [
	^ callingConventionDescriptionDictionary at: conventionName ifAbsentPut: [ lirFunction compilationTarget callingConventionDescriptionNamed: conventionName ]
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> findRegisterClassElementsForValue: value [
	allocatableRegisterClasses keysAndValuesDo: [ :key :values|
		(key canHoldValueOfType: value type) ifTrue: [ ^values ]
	].
	^ nil
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> findRegisterClassForValue: value [
	| valueType |
	value isInstruction ifTrue: [ 
		(value isAlloca and: [ value isOnlyUsedByLoadStoreAndGetElementPtrBase ]) ifTrue: [ ^ nil ]
	].

	valueType := value type.
	allocatableRegisterClasses keysDo: [ :key |
		(key canHoldValueOfType: valueType) ifTrue: [ ^ key ]
	].
	^ nil
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> findScratchRegisterClassElementsForValue: value [
	scratchRegisterClasses keysAndValuesDo: [ :key :values|
		(key canHoldValueOfType: value type) ifTrue: [ ^values ]
	].
	^ nil
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> findScratchRegisterClassForValue: value [
	scratchRegisterClasses keysDo: [ :key |
		(key canHoldValueOfType: value type) ifTrue: [ ^ key ]
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

{ #category : #initialization }
SLVMRegisterAllocator >> initialize [
	super initialize.
	callingConventionDescriptionDictionary := IdentityDictionary new.
	usedRegisters := Set new.
	
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> instruction: instruction translationDo: aBlock [
	aBlock value
	
]

{ #category : #accessing }
SLVMRegisterAllocator >> lirFunction [
	^ lirFunction
]

{ #category : #accessing }
SLVMRegisterAllocator >> lirFunction: anObject [
	lirFunction := anObject
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> mapSSA: value toSpillLocation: local [
	lirFunction mapSSA: value toStackVariable: local
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> moveInstruction: instruction resultInRegister: register with: codeGenerator [
	codeGenerator moveRegister: register toLocal: (lirFunction variableMap at: instruction).
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> moveInstruction: instruction toRegister: register with: codeGenerator [
	self moveInstructionSpilledValue: instruction toRegister: register with: codeGenerator
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> moveInstruction: instruction toRegisterLow: registerLow high: registerHigh with: codeGenerator [
	codeGenerator moveLocal: (lirFunction variableMap at: instruction) toRegisterLow: registerLow registerHigh: registerHigh
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> moveInstruction: instruction value: value toMemoryWith: codeGenerator [
	value isConstant ifTrue: [
		^ codeGenerator putConstantInConstantZone: value
	] ifFalse: [
		^ lirFunction variableMap at: value
	]
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> moveInstruction: instruction value: value toRegisterForPushingWith: codeGenerator [
	| register registerClass  |
	registerClass := self findScratchRegisterClassElementsForValue: value.
	register := registerClass first.
	self usedScratchRegister: register.
	
	value isConstant ifTrue: [
		codeGenerator moveConstant: value toRegister: register.
	] ifFalse: [
		codeGenerator moveLocal: (lirFunction variableMap at: value) type: value type toRegister: register.
	].

	^ register
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> moveInstruction: instruction value: value toRegisterOrLocalForPushingWith: codeGenerator [
	value isConstant ifFalse: [ 
		^ lirFunction variableMap at: value
	].
	^ self moveInstruction: instruction value: value toRegisterForPushingWith: codeGenerator

]

{ #category : #'public interface' }
SLVMRegisterAllocator >> moveInstruction: instruction value: value toRegisterWith: codeGenerator scratchIndex: scratchIndex [
	| register registerClass |
	registerClass := self findScratchRegisterClassElementsForValue: value.
	register := registerClass at: scratchIndex.
	self usedScratchRegister: register.
	
	value isConstant ifTrue: [
		codeGenerator moveConstant: value toRegister: register.
	] ifFalse: [
		codeGenerator moveLocal: (lirFunction variableMap at: value) type: value type toRegister: register.
	].

	^ register
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> moveInstructionSpilledValue: instruction toRegister: register with: codeGenerator [
	codeGenerator moveLocal: (lirFunction variableMap at: instruction) type: instruction type toRegister: register
]

{ #category : #'calling conventions' }
SLVMRegisterAllocator >> spillCalledRegisterForConvention: conventionDescription at: instruction with: translator [
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> translateBasicBlock: bb with: translator [
	translator translateBasicBlock: bb
]

{ #category : #'public interface' }
SLVMRegisterAllocator >> translateBasicBlocks: basicBlocks with: translator [
	basicBlocks do: [ :bb |
		self translateBasicBlock: bb with: translator
	]
]

{ #category : #'calling conventions' }
SLVMRegisterAllocator >> unspillCalledRegisterForConvention: convention at: instruction with: translator [
]

{ #category : #accessing }
SLVMRegisterAllocator >> usedRegisters [
	^ usedRegisters
]

{ #category : #accessing }
SLVMRegisterAllocator >> usedScratchRegister: scratchRegister [
	usedRegisters add: scratchRegister
]

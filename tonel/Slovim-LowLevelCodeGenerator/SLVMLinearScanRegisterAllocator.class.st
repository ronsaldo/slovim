"
I am a register allocator that uses the linear scan algorithm.

"
Class {
	#name : #SLVMLinearScanRegisterAllocator,
	#superclass : #SLVMRegisterAllocator,
	#instVars : [
		'liveRanges',
		'freeSpillLocations',
		'freeRegisters'
	],
	#category : #'Slovim-LowLevelCodeGenerator-RegisterAllocation'
}

{ #category : #'public interface' }
SLVMLinearScanRegisterAllocator >> allocateInstructionResultRegister: instruction [
	| range |
	range := liveRanges at: instruction livenessIndex.
	range register ifNotNil: [
		^ range register
	].

	^ super allocateInstructionResultRegister: instruction
]

{ #category : #'public interface' }
SLVMLinearScanRegisterAllocator >> allocateRegisters [
	| activeRangeClasses element registerClass currentActiveRanges activeMemoryRanges availableRegisters spilledRange activeRangesAtCall |
	self buildAllocatableRegisterClasses: callingConvention allocatableRegisters.
	self buildScratchRegisterClasses: callingConvention scratchRegisters.
	liveRanges := SLVMLinearRangeLivenessAnalyzer analyze: function.
	
	freeSpillLocations := Dictionary new.
	freeRegisters := Dictionary new.
	allocatableRegisterClasses keysAndValuesDo: [ :key :value |
		freeRegisters at: key put: (allocatableRegisterClasses at: key) copy
	].
	
	activeMemoryRanges := SortedCollection sortBlock: [ :a :b | a end < b end ].
	activeRangeClasses := Dictionary new.
	
	liveRanges select: #isConsideredForRegisterAllocation thenDo: [ :range |
		element := range element.

		"Spill location allocation"
		element isFunctionArgument ifTrue: [
			range spillLocation: (lirFunction variableMap at: element)
		] ifFalse: [ 
			self removeExpiredRangesUntil: range start from: activeMemoryRanges do: [:expiredRange |
				self freeSpillLocation: expiredRange spillLocation.
			].
			range spillLocation: (self allocateSpillLocationFor: element type).
			self mapSSA: element toSpillLocation: range spillLocation.
			activeMemoryRanges add: range.
		].

		"Register allocation."
		registerClass := self findRegisterClassForValue: element.
		registerClass ifNotNil: [
			activeRangeClasses valuesDo: [ :activeRanges |
				self removeExpiredRangesUntil: range start from: activeRanges do: [:expiredRange |
					self freeRegister: expiredRange register.
				].
			].
	
			currentActiveRanges := activeRangeClasses at: registerClass ifAbsentPut: [
				SortedCollection sortBlock: [ :a :b | a end < b end ]
			].
	
			availableRegisters := freeRegisters at: registerClass.
			availableRegisters ifEmpty: [
				"Spill here."
				spilledRange := currentActiveRanges last.
				spilledRange end > range end ifTrue: [ 
					"range spillRange: spilledRange."
					spilledRange register: nil.
					range register: spilledRange register.
					currentActiveRanges removeLast.
					currentActiveRanges add: range.
				] ifFalse: [
					"Range is spilled. Nothing required."
				]
			] ifNotEmpty: [
				range register: availableRegisters last.
				availableRegisters removeLast.
				usedRegisters add: range register.
				currentActiveRanges add: range.
			]
		].

		"Calls and message send may need to perform temporary spilling of registers owned by called function."
		element isInstruction ifTrue: [
			(element isCall or: [ element isMessageSend ]) ifTrue: [
				activeRangesAtCall := OrderedCollection new.
				activeRangeClasses valuesDo: [ :callRanges | activeRangesAtCall addAll: callRanges ].
				range activeRanges: activeRangesAtCall asArray
			].
		]
	].

]

{ #category : #'as yet unclassified' }
SLVMLinearScanRegisterAllocator >> allocateSpillLocationFor: type [
	| spillClass freeLocations spillLocation |
	spillClass := type sizeAndAlignment.
	freeLocations := freeSpillLocations at: spillClass ifAbsentPut: [ OrderedCollection new ].
	freeLocations ifNotEmpty: [
		spillLocation := freeLocations last.
		freeLocations removeLast.
	] ifEmpty: [
		spillLocation := lirFunction stackFrame createLocal: spillClass
	].

	^ spillLocation
]

{ #category : #'as yet unclassified' }
SLVMLinearScanRegisterAllocator >> emitPrologueWith: codeGenerator [
	self loadArgumentsIntoRegisterWith: codeGenerator
]

{ #category : #'as yet unclassified' }
SLVMLinearScanRegisterAllocator >> freeRegister: register [
	self halt
]

{ #category : #'as yet unclassified' }
SLVMLinearScanRegisterAllocator >> freeSpillLocation: spillLocation [
	spillLocation ifNil: [ ^ self ].
	self halt.
]

{ #category : #'as yet unclassified' }
SLVMLinearScanRegisterAllocator >> loadArgumentsIntoRegisterWith: codeGenerator [
	| argumentRange |
	function arguments do: [ :argument | 
		argumentRange := liveRanges at: argument livenessIndex.
		argumentRange register ifNotNil: [
			codeGenerator moveLocal: argumentRange spillLocation type: argument type toRegister: argumentRange register.
		]
	].

]

{ #category : #'public interface' }
SLVMLinearScanRegisterAllocator >> moveInstruction: instruction toRegister: register with: codeGenerator [
	| range livenessIndex |
	livenessIndex := instruction livenessIndex.
	livenessIndex ifNotNil: [
		range := liveRanges at: livenessIndex.
		range register ifNotNil: [
			^ codeGenerator moveRegister: range register toRegister: register
		].
	].

	^ super moveInstruction: instruction toRegister: register with: codeGenerator
]

{ #category : #'public interface' }
SLVMLinearScanRegisterAllocator >> moveInstruction: instruction value: value toMemoryWith: codeGenerator [
	| range livenessIndex |
	livenessIndex := value livenessIndex.
	livenessIndex ifNotNil: [
		range := liveRanges at: livenessIndex.
		range register ifNotNil: [
			codeGenerator moveRegister: range register toMemory: range spillLocation.
			^ range spillLocation
		].
	].

	^ super moveInstruction: instruction value: value toMemoryWith: codeGenerator
]

{ #category : #'public interface' }
SLVMLinearScanRegisterAllocator >> moveInstruction: instruction value: value toRegisterForPushingWith: codeGenerator [
	| range livenessIndex |
	livenessIndex := value livenessIndex.
	livenessIndex ifNotNil: [
		range := liveRanges at: livenessIndex.
		range register ifNotNil: [
			^ range register
		].
	].

	^ super moveInstruction: instruction value: value toRegisterForPushingWith: codeGenerator
]

{ #category : #'public interface' }
SLVMLinearScanRegisterAllocator >> moveInstruction: instruction value: value toRegisterOrLocalForPushingWith: codeGenerator [
	| range livenessIndex |
	livenessIndex := value livenessIndex.
	livenessIndex ifNotNil: [
		range := liveRanges at: livenessIndex.
		range register ifNotNil: [
			^ range register
		].
	].

	^ super moveInstruction: instruction value: value toRegisterOrLocalForPushingWith: codeGenerator
]

{ #category : #'public interface' }
SLVMLinearScanRegisterAllocator >> moveInstruction: instruction value: value toRegisterWith: codeGenerator scratchIndex: scratchIndex [
	| range livenessIndex |
	livenessIndex := value livenessIndex.
	livenessIndex ifNotNil: [
		range := liveRanges at: livenessIndex.
		range register ifNotNil: [
			^ range register
		].
	].

	^ super moveInstruction: instruction value: value toRegisterWith: codeGenerator scratchIndex: scratchIndex
]

{ #category : #removing }
SLVMLinearScanRegisterAllocator >> removeExpiredRangesUntil: date from: rangeList do: aBlock [
	[rangeList isNotEmpty and: [ rangeList first end < date]] whileTrue: [
		aBlock value: rangeList first.
		rangeList removeFirst
	]
]

{ #category : #'calling conventions' }
SLVMLinearScanRegisterAllocator >> spillCalledRegisterForConvention: conventionName at: instruction with: translator [
	| convention range calledRegisters |
	convention := self callingConventionDescriptionNamed: conventionName.
	calledRegisters := convention calledRegisters.
	range := liveRanges at: instruction livenessIndex.
	range activeRanges do: [ :activeRange |
		(activeRange ~~ range and:
		[ activeRange end > range start and:
		[ activeRange register isNotNil and:
		[ calledRegisters includes: activeRange register ] ] ]) ifTrue: [
			translator moveRegister: activeRange register toLocal: activeRange spillLocation
		]
	].

]

{ #category : #'calling conventions' }
SLVMLinearScanRegisterAllocator >> unspillCalledRegisterForConvention: conventionName at: instruction with: translator [
	| convention range calledRegisters |
	convention := self callingConventionDescriptionNamed: conventionName.
	calledRegisters := convention calledRegisters.
	range := liveRanges at: instruction livenessIndex.
	range activeRanges do: [ :activeRange |
		(activeRange ~~ range and:
		[ activeRange end > range start and:
		[ activeRange register isNotNil and:
		[ calledRegisters includes: activeRange register ] ] ]) ifTrue: [
			translator moveLocal: activeRange spillLocation type: activeRange element type toRegister: activeRange register
		]
	].

]

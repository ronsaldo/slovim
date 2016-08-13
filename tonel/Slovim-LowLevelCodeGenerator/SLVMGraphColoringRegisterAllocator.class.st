Class {
	#name : #SLVMGraphColoringRegisterAllocator,
	#superclass : #SLVMRegisterAllocator,
	#category : #'Slovim-LowLevelCodeGenerator-RegisterAllocation'
}

{ #category : #'as yet unclassified' }
SLVMGraphColoringRegisterAllocator >> allocateInstructionResultRegister: instruction [
	| registerClass |
	registerClass := self findRegisterClassForValue: instruction.
	self flag: 'Ensure this register is available'.
	^ registerClass last
]

{ #category : #'as yet unclassified' }
SLVMGraphColoringRegisterAllocator >> allocateRegisters [
	| liveness graph |
	self buildAllocatableRegisterClasses: lirFunction compilationTarget allocatableRegisters.
	liveness := SLVMLivenessAnalyzer analyze: function.
	
	graph := SLVMInterferenceGraphBuilder buildForLiveness: liveness.
	self allocateSpillLocations: graph
]

{ #category : #'graph coloring' }
SLVMGraphColoringRegisterAllocator >> allocateSpillLocations: interferenceGraph [
	| order usedColors usedCount stackFrame usedColorClasses spillClass compilationTarget temporariesWithClasses temporaries reusedIndex local |
	interferenceGraph nodes do: [ :node | node spillIndex: nil ].
	stackFrame := lirFunction stackFrame.
	order := self graphColoringOrdering: interferenceGraph.
	usedColorClasses := Dictionary new.
	temporariesWithClasses := Dictionary new.
	compilationTarget := lirFunction compilationTarget.
	
	order select: [:node | node variable isFunctionArgument not and: [ (node variable type sizeForTarget: compilationTarget) > 0] ] thenDo: [ :node |
		spillClass := node spillClassForTarget: compilationTarget.
		usedColors := usedColorClasses at: spillClass ifAbsentPut: [ OrderedCollection new ].
		temporaries := temporariesWithClasses at: spillClass ifAbsentPut: [ OrderedCollection new ].
		usedColors atAllPut: false.
		usedCount := 0.

		node interferences do: [ :interference |
			((interference spillClassForTarget: compilationTarget) = spillClass and: [ interference spillIndex isNotNil ]) ifTrue: [
				(usedColors at: interference spillIndex) ifFalse: [ 
					usedColors at: interference spillIndex put: true.
					usedCount := usedCount + 1
				]
			]
		].
	
		usedCount = usedColors size ifTrue: [
			local := stackFrame createLocal: spillClass.
			node spillIndex: usedCount + 1.
			usedColors add: true.
			temporaries add: local.
			self mapSSA: node variable toSpillLocation: local.
		] ifFalse: [
			reusedIndex := usedColors findFirst: [:el | el == false].
			local := temporaries at: reusedIndex.
			node spillIndex: reusedIndex.
			self mapSSA: node variable toSpillLocation: local.
		]
	].

]

{ #category : #'graph coloring' }
SLVMGraphColoringRegisterAllocator >> graphColoringOrdering: interferenceGraph [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SLVMGraphColoringRegisterAllocator >> moveInstruction: instruction resultInRegister: register with: codeGenerator [
	codeGenerator moveRegister: register toLocal: (lirFunction variableMap at: instruction).
]

{ #category : #'as yet unclassified' }
SLVMGraphColoringRegisterAllocator >> moveInstruction: instruction toRegister: register with: codeGenerator [
	codeGenerator moveLocal: (lirFunction variableMap at: instruction) toRegister: register
]

{ #category : #'as yet unclassified' }
SLVMGraphColoringRegisterAllocator >> moveInstruction: instruction toRegisterLow: registerLow high: registerHigh with: codeGenerator [
	codeGenerator moveLocal: (lirFunction variableMap at: instruction) toRegisterLow: registerLow registerHigh: registerHigh
]

{ #category : #'as yet unclassified' }
SLVMGraphColoringRegisterAllocator >> moveInstruction: instruction value: value toRegisterWith: codeGenerator [
	| register registerClass registerOrSpillParamCount constantParamCount valueIndex |
	registerClass := self findRegisterClassForValue: value.
	registerOrSpillParamCount := 0.
	constantParamCount := 0.
	valueIndex := nil.
	
	instruction parameters do: [ :param | 
		(self findRegisterClassForValue: param) == registerClass ifTrue: [
			param isConstant ifTrue: [
				constantParamCount := constantParamCount + 1.
				param == value ifTrue: [ valueIndex := constantParamCount ]
			] ifFalse: [
				registerOrSpillParamCount := registerOrSpillParamCount + 1.
				param == value ifTrue: [ valueIndex := registerOrSpillParamCount ]
			]
		]
	].

	self assert: valueIndex isNotNil.
	value isConstant ifTrue: [
		register := registerClass at: valueIndex + registerOrSpillParamCount.
		codeGenerator moveConstant: value toRegister: register.
	] ifFalse: [
		register := registerClass at: valueIndex.
		codeGenerator moveLocal: (lirFunction variableMap at: value) toRegister: register.
	].

	^ register
]

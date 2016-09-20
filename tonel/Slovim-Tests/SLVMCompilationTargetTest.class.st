"
A SLVMCompilationTargetTest is a test class for testing the behavior of SLVMCompilationTarget
"
Class {
	#name : #SLVMCompilationTargetTest,
	#superclass : #TestCase,
	#instVars : [
		'target'
	],
	#category : #'Slovim-Tests'
}

{ #category : #running }
SLVMCompilationTargetTest >> setUp [
	target := SLVM32BitsPointerCompilationTarget new.
]

{ #category : #'as yet unclassified' }
SLVMCompilationTargetTest >> testBuildMinf [
	| module minf returnFirst returnSecond cmp |
	module := target newModule.
	minf := module functionName: #minf arguments: { target float . target float } returnType: target float.
	minf buildWithArguments: [ :builder :first :second |
		builder basicBlockNamed: #entry do: [ :entry |
			returnFirst := builder basicBlockNamed: #first do: [ :block |
				builder return: first
			].
			returnSecond := builder basicBlockNamed: #second do: [ :block |
				builder return: second
			].
	
			cmp := builder ofle: first with: second.
			builder branch: cmp ifTrue: returnFirst ifFalse: returnSecond
		]
	].

	self assert: minf basicBlocks size equals: 3.
]

{ #category : #tests }
SLVMCompilationTargetTest >> testBuildWithArguments [
	| module minf |
	module := target newModule.
	minf := module functionName: #minf arguments: { target float . target float } returnType: target float.
	minf buildWithArguments: [ :builder :first :second |
		self assert: builder class equals: SLVMBuilder.
		self assert: first equals: minf arguments first.
		self assert: second equals: minf arguments second.
	].

]

{ #category : #tests }
SLVMCompilationTargetTest >> testCreateFunction [
	| module minf |
	module := target newModule.
	minf := module functionName: #minf arguments: { target float . target float } returnType: target float.
	self assert: minf arguments size equals: 2.
	self assert: (minf arguments collect: #type) equals: {SLVMType floatType . SLVMType floatType}.
	self assert: minf functionType returnType equals: SLVMType floatType.
]

{ #category : #tests }
SLVMCompilationTargetTest >> testNewModule [
	| module |
	module := target newModule.
	self assert: module compilationTarget equals: target
]

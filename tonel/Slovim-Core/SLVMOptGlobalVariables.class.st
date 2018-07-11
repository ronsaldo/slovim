Class {
	#name : #SLVMOptGlobalVariables,
	#superclass : #SLVMModuleOptimizationPass,
	#category : #'Slovim-Core-Optimizations'
}

{ #category : #'as yet unclassified' }
SLVMOptGlobalVariables >> passOnModule: aModule [
	| potentialConstants |
	potentialConstants := IdentitySet new.
	aModule allGlobalValuesDo: [ :global |
		(global isGlobalVariable and: [ global isPrivate and: [ global readOnly not ]]) ifTrue: [
			(global valueType isDynamicObjectPointerType not and: [global customSection isNil and: [global headerValue isNil]]) ifTrue: [
				potentialConstants add: global
			]
		]
	].

	"We can only promote these variables into a constant only if there are used by a Load instruction."
	aModule allInstructionsDo: [ :ins |
		ins isLoad ifFalse: [ 
			ins parameters do: [ :param |
				(potentialConstants includes: param) ifTrue: [ 
					potentialConstants remove: param
				].
			]
		]
	].

	"Promote these variables into constants"
	potentialConstants do: [ :pot |
		pot readOnly: true
	]
]

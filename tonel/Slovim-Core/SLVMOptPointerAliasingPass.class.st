Class {
	#name : #SLVMOptPointerAliasingPass,
	#superclass : #SLVMFunctionOptimizationPass,
	#category : #'Slovim-Core-Optimizations'
}

{ #category : #applying }
SLVMOptPointerAliasingPass >> analyzeAliasedPointersOn: aFunction [
	| aliasedPointers unaliasedPointers analyzedPointers |
	aliasedPointers := SLVMDisjointSets new.
	unaliasedPointers := SLVMDisjointSets new.
	analyzedPointers := IdentitySet new.
	aliasedPointers addSets: (self findAliasedArguments: aFunction arguments).

	aFunction arguments do: [ :arg |
		arg type isPointerType ifTrue: [
			self findAliasesOfPointers: arg instructionReferences derivedOf: arg intoMay: aliasedPointers mayNot: unaliasedPointers visited: analyzedPointers
		].
	].

	aFunction allInstructionsDo: [ :instruction |
		self findAliasesIntroducedBy: instruction intoMay: aliasedPointers mayNot: unaliasedPointers visited: analyzedPointers
	].

	^ {aliasedPointers . unaliasedPointers}
]

{ #category : #applying }
SLVMOptPointerAliasingPass >> findAliasedArguments: arguments [
	| aliasedArguments |
	arguments ifEmpty: [ ^ #() ].
	
	aliasedArguments := OrderedCollection new.
	arguments do: [ :arg |
		arg type isPointerType ifTrue: [
			aliasedArguments add: arg.
		]
	].

	^ { aliasedArguments }
]

{ #category : #applying }
SLVMOptPointerAliasingPass >> findAliasesIntroducedBy: instruction intoMay: aliasedPointers mayNot: unaliasedPointers visited: visitedPointers [
	instruction isBitCast ifTrue: [
		aliasedPointers join: instruction source with: instruction.
		instruction type isPointerType ifTrue: [ 
			self findAliasesOfPointers: instruction instructionReferences derivedOf: instruction intoMay: aliasedPointers mayNot: unaliasedPointers visited: visitedPointers.
		].
	
		^ self
	].

	instruction isGetElementPointer ifTrue: [
		instruction pointer type isPointerType ifTrue: [ 
			aliasedPointers join: instruction pointer with: instruction.
			self findAliasesOfPointers: instruction instructionReferences derivedOf: instruction intoMay: aliasedPointers mayNot: unaliasedPointers  visited: visitedPointers.
			^ self
		].
	].

	instruction isAlloca ifTrue: [
		self findAliasesOfPointers: instruction instructionReferences derivedOf: instruction intoMay: aliasedPointers mayNot: unaliasedPointers  visited: visitedPointers.
	].

]

{ #category : #applying }
SLVMOptPointerAliasingPass >> findAliasesOfPointers: derivedPointers derivedOf: parentPointer intoMay: aliasedPointers mayNot: unaliasedPointers visited: visitedPointers [
	| unaliased aliased |
	(visitedPointers includes: parentPointer) ifTrue: [ ^ self ].
	visitedPointers add: parentPointer.
	
	unaliased := OrderedCollection new.
	aliased := OrderedCollection new.
	aliased add: parentPointer.
	
	derivedPointers do: [ :derived |
		derived type isPointerType ifTrue: [ 
			(derived isGetElementPointer and: [ derived hasConstantIndices ]) ifTrue: [ 
				unaliased add: derived
			] ifFalse: [
				(derived isLoad or: [ derived isStore ]) ifFalse: [ 
					aliased add: derived.
					self findAliasesOfPointers: derived instructionReferences derivedOf: derived intoMay: aliasedPointers mayNot: unaliasedPointers visited: visitedPointers
				]
			]
		]
	].

	unaliasedPointers addSet: unaliased.
	aliasedPointers addSet: aliased.
]

{ #category : #applying }
SLVMOptPointerAliasingPass >> optimizeLoadsAndStoresIn: bb mayAlias: aliasedPointers mayNotAlias: unaliasedPointers [
	| seenLoads pointer |
	seenLoads := Dictionary new.

	bb instructionsDo: [ :instruction |
		((instruction isLoad or: [instruction isStore]) and: [instruction volatile not]) ifTrue: [ 
			pointer := instruction variable.
			
			"Try to always replace the loads"
			instruction isLoad ifTrue: [
				seenLoads at: pointer ifPresent: [ :previous |
					instruction replaceWith: previous
				] ifAbsentPut: [ instruction ]
			].

			instruction isStore ifTrue: [
				seenLoads keys copy do: [ :previousLoadPointer |
					((aliasedPointers is: pointer joinedWith: previousLoadPointer) and: [
					(unaliasedPointers is: pointer joinedWith: previousLoadPointer) not ]) ifTrue: [
						seenLoads removeKey: previousLoadPointer
					]
				]
			].
		]
	]
]

{ #category : #applying }
SLVMOptPointerAliasingPass >> optimizeLoadsAndStoresOn: aFunction mayAlias: aliasedPointers mayNotAlias: unaliasedPointers [
	aFunction basicBlocks do: [ :bb |
		self optimizeLoadsAndStoresIn: bb mayAlias: aliasedPointers mayNotAlias: unaliasedPointers
	].

]

{ #category : #applying }
SLVMOptPointerAliasingPass >> passOnFunction: aFunction [
	| aliasedAndUnaliasedPointers |

	self removeDuplicatedGEPsOn: aFunction.
	aliasedAndUnaliasedPointers := self analyzeAliasedPointersOn: aFunction.
	self optimizeLoadsAndStoresOn: aFunction mayAlias: aliasedAndUnaliasedPointers first mayNotAlias: aliasedAndUnaliasedPointers second

]

{ #category : #applying }
SLVMOptPointerAliasingPass >> removeDuplicatedGEPsOn: aFunction [
	| foundGEPs |
	foundGEPs := Dictionary new.
	aFunction allInstructionsDo: [ :instruction |
		instruction isGetElementPointer ifTrue: [
			self replaceGEP: instruction fromPreviousIn: foundGEPs
		]
	].

]

{ #category : #applying }
SLVMOptPointerAliasingPass >> replaceGEP: instruction fromPreviousIn: foundGEPs [
	"Coalerce constant GEPs"
	| pointer indices newInstruction coalescedIndices gepSignature matchingVersions |
	pointer := instruction pointer.
	indices := instruction indices.
	
	(pointer isInstruction and: [ pointer isGetElementPointer ]) ifTrue: [ 
		(instruction hasConstantIndices and: [ pointer firstIndex isConstantValue ]) ifTrue: [
			coalescedIndices := pointer indices allButLast ,
				{pointer lastIndex + indices first},
				indices allButFirst.
			newInstruction := SLVMGetElementPointer
				pointer: pointer pointer
				indices: coalescedIndices.
			instruction replaceWithNewInstruction: newInstruction.
			^ self replaceGEP: newInstruction fromPreviousIn: foundGEPs
		].
	].

	gepSignature := { pointer . indices }.
	matchingVersions := foundGEPs at: gepSignature ifAbsentPut: [ OrderedCollection new ].
	matchingVersions do: [ :previousVersion |
		(previousVersion dominates: instruction) ifTrue: [
			instruction replaceWith: previousVersion.
			^ self
		]
	].

	matchingVersions add: instruction

]

Class {
	#name : #SLVMOptInline,
	#superclass : #SLVMFunctionOptimizationPass,
	#instVars : [
		'maxDepth',
		'inlinedFunctions',
		'postInlineOptimizations',
		'functionGraphAnalysisState',
		'keepStructuredControlFlow'
	],
	#category : #'Slovim-Core-Optimizations'
}

{ #category : #applying }
SLVMOptInline >> analyzeFunctionGraph: aFunction [
	| state returnCount |
	functionGraphAnalysisState at: aFunction ifPresent: [ :oldState |
		oldState first == #gray ifTrue: [ aFunction propertyAt: #recursive put: true ].
		^ self
	].

	state := { #gray . 0 }.
	functionGraphAnalysisState at: aFunction put: state.
	returnCount := 0.
	
	aFunction basicBlocks do: [ :bb |
		bb instructionsDo: [ :instruction |
			(instruction isCall and: [ instruction functionValue isFunction ]) ifTrue: [
				self analyzeFunctionGraph: instruction functionValue
			].
		
			(instruction isReturn or: [ instruction isReturnVoid ]) ifTrue: [
				returnCount := returnCount + 1
			]
		]
	].
	
	state at: 1 put: #black.
	state at: 2 put: returnCount.
]

{ #category : #'as yet unclassified' }
SLVMOptInline >> findSomeInlineableCall: basicBlock [
	| function |
	basicBlock instructionsDo: [ :instruction |
		instruction isCall ifTrue: [
			function := instruction functionValue.
			function isFunction ifTrue: [
				((function propertyAt: #recursive ifAbsent: [ false ]) not and:
				[ keepStructuredControlFlow not or: [ (functionGraphAnalysisState at: function) second < 2] ] ) ifTrue: [
					^ instruction
				]
			]
		]
	].

	^ nil
]

{ #category : #'as yet unclassified' }
SLVMOptInline >> flattening [
	maxDepth := -1
]

{ #category : #applying }
SLVMOptInline >> initialize [
	super initialize.
	inlinedFunctions := Set new.
	functionGraphAnalysisState := Dictionary new.
	postInlineOptimizations := #().
	keepStructuredControlFlow := false.
]

{ #category : #'as yet unclassified' }
SLVMOptInline >> inlineFunction: aFunction [
	| pendingBlocks currentBlock callInstruction continuationBlock resultValue entryPointAndResult entryPoint |
	(inlinedFunctions includes: aFunction) ifTrue: [ ^ self ].
	inlinedFunctions add: aFunction.
	
	pendingBlocks := Set new.
	pendingBlocks addAll: aFunction basicBlocks.
	
	[ pendingBlocks isEmpty ] whileFalse: [
		currentBlock := pendingBlocks anyOne.
		pendingBlocks remove: currentBlock.
		
		callInstruction := self findSomeInlineableCall: currentBlock.
		callInstruction ifNotNil: [
			continuationBlock := callInstruction splitBasicBlock.
			self inlineFunction: callInstruction functionValue.
			
			entryPointAndResult := self inlineFunctionContent: callInstruction functionValue into: aFunction arguments: callInstruction arguments continuation: continuationBlock.
			entryPoint := entryPointAndResult first.
			resultValue := entryPointAndResult second.
			
			currentBlock add: ((SLVMJump destination: entryPoint) name: #inlineJump).
			
			resultValue
				ifNotNil: [ callInstruction replaceWith: resultValue ]
				ifNil: [ callInstruction removeFromBlock  ].
				
			pendingBlocks add: continuationBlock
		]
	].

	postInlineOptimizations do: [ :optimization | optimization passOnFunction: aFunction ].
]

{ #category : #'as yet unclassified' }
SLVMOptInline >> inlineFunctionContent: sourceFunction into: targetFunction arguments: arguments continuation: continuationBlock [
	| newBlocks newBlock substitutionDictionary newInstruction resultPhi return result movedAllocas sourceFirstBlock targetFirstBlock |
	newBlocks := OrderedCollection new.
	movedAllocas := OrderedCollection new.
	substitutionDictionary := IdentityDictionary new.

	"Copy the vertices of the graph"
	sourceFunction arguments doWithIndex: [ :arg :index |
		substitutionDictionary at: arg put: (arguments at: index)
	].
 	
	sourceFirstBlock := sourceFunction basicBlocks first.
	targetFirstBlock := targetFunction basicBlocks first.
	
	sourceFunction basicBlocks do: [ :bb |
		newBlock := SLVMBasicBlock new name: bb name.
		newBlocks add: newBlock.
		targetFunction addBasicBlock: newBlock.
		substitutionDictionary at: bb put: newBlock.
		
		bb instructionsDo: [ :instr |
			newInstruction := instr copy.
			substitutionDictionary at: instr put: newInstruction.
			(newInstruction isAlloca and: [ bb == sourceFirstBlock ]) ifTrue: [
				targetFirstBlock addFirst: newInstruction.
				movedAllocas add: newInstruction.
			] ifFalse: [ 
				newBlock addQuiet: newInstruction
			]
		] 
	].

	"Fix the edges of the graph"
	movedAllocas do: [ :instr | instr applySubstitutions: substitutionDictionary ].
	newBlocks do: [ :bb |
		bb instructionsDo: [ :instr |
			instr applySubstitutions: substitutionDictionary
		]
	].

	newBlocks do: #computeSuccessors.
	newBlocks do: [:bb |
		bb lastInstruction isTerminator ifTrue: [ bb lastInstruction addUnreachableSuccessors ]
	].

	"Transform the return into jumps".
	sourceFunction functionType returnType isVoidType ifTrue: [ 
		newBlocks do: [:bb |
			bb lastInstruction isReturnVoid ifTrue: [
				bb lastInstruction removeFromBlock.
				bb add: ((SLVMJump destination: continuationBlock) name: bb function generateSymbol)
			]
		].
	
		^ {newBlocks first . nil}
	] ifFalse: [
		resultPhi := nil.
		newBlocks do: [:bb |
			return := bb lastInstruction.
			return isReturn ifTrue: [
				resultPhi ifNil: [
					resultPhi := (SLVMPhi type: return value type) name: bb function generateSymbol.
					continuationBlock addFirst: resultPhi
				].
		
				resultPhi addValue: return value from: bb.
				bb lastInstruction removeFromBlock.
				bb add: ((SLVMJump destination: continuationBlock) name: bb function generateSymbol)
			]
		].
	
		(resultPhi isNil or: [ resultPhi parameters size = 0 ]) ifTrue: [
			"Undefined result"
			self halt.
		].
	
		resultPhi parameters size = 1 ifTrue: [
			result := resultPhi parameters first.
			resultPhi removeFromBlock.
			^ {newBlocks first . result}
		].
	
		^ {newBlocks first . resultPhi}
	]
]

{ #category : #accessing }
SLVMOptInline >> keepStructuredControlFlow [
	^ keepStructuredControlFlow
]

{ #category : #accessing }
SLVMOptInline >> keepStructuredControlFlow: anObject [
	keepStructuredControlFlow := anObject
]

{ #category : #applying }
SLVMOptInline >> passOnFunction: aFunction [
	aFunction isFunction ifFalse: [ ^ self ].
	self analyzeFunctionGraph: aFunction.
	self inlineFunction: aFunction.
	
]

{ #category : #accessing }
SLVMOptInline >> postInlineOptimizations [
	^ postInlineOptimizations
]

{ #category : #accessing }
SLVMOptInline >> postInlineOptimizations: anObject [
	postInlineOptimizations := anObject
]

Class {
	#name : #SLVMOptInline,
	#superclass : #SLVMFunctionOptimizationPass,
	#instVars : [
		'inlinedFunctions',
		'postInlineOptimizations',
		'functionGraphAnalysisState',
		'keepStructuredControlFlow',
		'inliningMandatory'
	],
	#category : #'Slovim-Core-Optimizations'
}

{ #category : #'as yet unclassified' }
SLVMOptInline class >> withStructuredControlFlow [
	^ self new keepStructuredControlFlow: true; yourself
]

{ #category : #applying }
SLVMOptInline >> analyzeFunctionGraph: aFunction [
	functionGraphAnalysisState at: aFunction ifPresent: [ :oldState |
		oldState == #gray ifTrue: [ aFunction propertyAt: #recursive put: true ].
		^ self
	].

	functionGraphAnalysisState at: aFunction put: #gray.
	"We should always try to use functions with canonical structured control flow."
	aFunction ensureCanonicalStructuredControlFlow.
	
	aFunction basicBlocks do: [ :bb |
		bb instructionsDo: [ :instruction |
			(instruction isCall and: [ instruction functionValue isFunction ]) ifTrue: [
				self analyzeFunctionGraph: instruction functionValue
			].
		
			instruction isGetThisContext ifTrue: [
				self flag: 'This is the place for vetting some functions'.
				aFunction propertyAt: #recursive put: true
			].
		]
	].
	
	functionGraphAnalysisState at: aFunction put: #black
]

{ #category : #'as yet unclassified' }
SLVMOptInline >> findSomeInlineableCall: basicBlock [
	| function |
	basicBlock instructionsDo: [ :instruction |
		instruction isCall ifTrue: [
			function := instruction functionValue.
			(function isFunction and: [function isNotEmpty]) ifTrue: [
				((function propertyAt: #recursive ifAbsent: [ false ]) not and:
				[ keepStructuredControlFlow not or: [ function hasCanonicalStructuredControlFlow ] ] ) ifTrue: [
					(inliningMandatory or:
					[function hasAlwaysInlineMode or:
					[function hasYesInlineMode]]) ifTrue: [ ^ instruction ].
				]
			]
		]
	].

	^ nil
]

{ #category : #applying }
SLVMOptInline >> initialize [
	super initialize.
	inlinedFunctions := Set new.
	functionGraphAnalysisState := Dictionary new.
	postInlineOptimizations := #().
	keepStructuredControlFlow := false.
	inliningMandatory := false
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

	self validateFunction: aFunction.
	postInlineOptimizations do: [ :optimization | optimization passOnFunction: aFunction ].
]

{ #category : #'as yet unclassified' }
SLVMOptInline >> inlineFunctionContent: sourceFunction into: targetFunction arguments: arguments continuation: continuationBlock [
	| substitutionDictionary |
	substitutionDictionary := IdentityDictionary new.
	
	"Replace the arguments"
	sourceFunction arguments doWithIndex: [ :arg :index |
		substitutionDictionary at: arg put: (arguments at: index)
	].
 	
	
	^ sourceFunction copyContentsInto: targetFunction valueMap: substitutionDictionary continuation: continuationBlock
]

{ #category : #accessing }
SLVMOptInline >> inliningMandatory [
	^ inliningMandatory
]

{ #category : #accessing }
SLVMOptInline >> inliningMandatory: anObject [
	inliningMandatory := anObject
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

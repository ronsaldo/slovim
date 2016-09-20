"
I am a liveness analyzer that computes treats the instructions as a linear stream and it computes linear ranges.
"
Class {
	#name : #SLVMLinearRangeLivenessAnalyzer,
	#superclass : #Object,
	#category : #'Slovim-Core-Analysis'
}

{ #category : #'public api' }
SLVMLinearRangeLivenessAnalyzer class >> analyze: aFunction [
	^ self new analyze: aFunction
]

{ #category : #public }
SLVMLinearRangeLivenessAnalyzer >> analyze: aFunction [
	| elementsWithRange |
	elementsWithRange := self createInitialRangesFor: aFunction.
	self computeEndingsOfRanges: elementsWithRange.
	^ elementsWithRange
]

{ #category : #private }
SLVMLinearRangeLivenessAnalyzer >> computeEndingsOfRanges: ranges [
	| element argumentRange |
	ranges do: [ :range |
		element := range element.
		element isSSAValue ifTrue: [ 
			element isFunctionArgument ifTrue: [
				"Make the arguments always alive, for now."
				range end: range start
			].
		
			element isInstruction ifTrue: [
				range end: range start.
				element instructionReferences do: [ :ref |
					range end: (range end max: ref livenessIndex)
				].
			
				element parameters do: [ :param |
					param isFunctionArgument ifTrue: [
						argumentRange := ranges at: param livenessIndex.
						argumentRange end: (argumentRange end max: range start)
					]
				]
			].
		]
	].

]

{ #category : #private }
SLVMLinearRangeLivenessAnalyzer >> createInitialRangesFor: aFunction [
	| elementsWithRange blockRange |
	elementsWithRange := OrderedCollection new.
	aFunction arguments do: [ :argument |
		argument livenessIndex: elementsWithRange size + 1.
		elementsWithRange add: (SLVMLivenessRange new
			element: argument;
			start: elementsWithRange size + 1;
			yourself).
	].

	aFunction basicBlocks do: [ :bb |
		blockRange := SLVMLivenessRange new
			element: bb;
			start: elementsWithRange size + 1.
		
		elementsWithRange add: blockRange.
		bb instructionsDo: [ :instruction |
			elementsWithRange add: (SLVMLivenessRange new
				element: instruction;
				start: elementsWithRange size + 1;
				yourself).
			instruction livenessIndex: elementsWithRange size.
		].
	
		blockRange end: elementsWithRange size.
	].

	^ elementsWithRange
]

"
I represent a closure inside a function. I can be instantiated into a normal function that receives the captured state in a structure pointer passed as the first parameter.
"
Class {
	#name : #SLVMClosureDefinition,
	#superclass : #SLVMFunction,
	#instVars : [
		'captures',
		'closureType',
		'normalFunctionTypes'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMClosureDefinition class >> module: module functionType: functionType [
	| var |
	var := self pointerSize: module compilationTarget pointerSize functionType: functionType.
	var compilationTarget: module compilationTarget.
	^ var
]

{ #category : #visiting }
SLVMClosureDefinition >> accept: aVisitor [
	^ aVisitor visitClosureDefinition: self
]

{ #category : #converting }
SLVMClosureDefinition >> asNormalFunction [
	| normalFunctionType normalFunction valueMap environmentArg environmentPointer prologueInstructions dynamicCaptureCount dynamicCaptureIndex normalCaptureIndex captureIndex capturePointer captureLoad firstBlock closureStructureType |
	self normalFunctionTypes.

	normalFunctionType := normalFunctionTypes first.
	closureStructureType := normalFunctionTypes third.
	
	normalFunction := SLVMFunction pointerSize: type size functionType: normalFunctionType.
	normalFunction makePrivate.
	normalFunction compilationTarget: compilationTarget.
	normalFunction gcStrategy: self gcStrategy.
	
	valueMap := IdentityDictionary new.
	arguments doWithIndex: [ :arg :index |
		valueMap at: arg put: (normalFunction arguments at: index + 1)
	].

	environmentArg := normalFunction arguments first.
	environmentPointer := SLVMGetElementPointer pointer: environmentArg indices: { SLVMConstant int: 0 . SLVMConstant int: closureStructureType types size - 1 }.
	environmentPointer name: #capturedEnvironmentPointer.

	prologueInstructions := OrderedCollection new.
	prologueInstructions add: environmentPointer.
	
	"Map the captures"	
	dynamicCaptureCount := 0.
	captures do: [ :cap |
		cap type isDynamicObjectPointerType ifTrue: [ 
			dynamicCaptureCount := dynamicCaptureCount + 1
		]
	].

	dynamicCaptureIndex := 0.
	normalCaptureIndex := 0.
	captures do: [ :cap |
		cap type isDynamicObjectPointerType ifTrue: [
			captureIndex := dynamicCaptureIndex.
			dynamicCaptureIndex := dynamicCaptureIndex + 1.
		] ifFalse: [
			captureIndex := dynamicCaptureCount + normalCaptureIndex.
			normalCaptureIndex := normalCaptureIndex + 1.
		].
	
		capturePointer := SLVMGetElementPointer pointer: environmentPointer indices: { SLVMConstant int: 0 . SLVMConstant int: captureIndex }.
		captureLoad := SLVMLoadInstruction variable: capturePointer.
		prologueInstructions
			add: capturePointer;
			add: captureLoad.
		valueMap at: cap put: captureLoad
	].

	"Copy the function contents"
	firstBlock := (self copyContentsInto: normalFunction valueMap: valueMap) first.
	
	"Add the prologue instructions, after the allocas"
	firstBlock addInstructionsAfterAllocas: prologueInstructions.
	^ normalFunction
]

{ #category : #accessing }
SLVMClosureDefinition >> captures [
	^ captures
]

{ #category : #accessing }
SLVMClosureDefinition >> closureType [
	^ closureType ifNil: [closureType := SLVMClosureType functionType: functionType captures: (captures collect: #type)]
]

{ #category : #initialization }
SLVMClosureDefinition >> createClosureCaptureOfType: aCaptureType [
	| capture |
	capture := SLVMClosureCapture new
		function: self;
		type: aCaptureType;
		index: captures size.
	captures add: capture.
	closureType := nil.
	^ capture
]

{ #category : #initialization }
SLVMClosureDefinition >> initialize [
	super initialize.
	captures := OrderedCollection new.
]

{ #category : #testing }
SLVMClosureDefinition >> isClosureDefinition [
	^ true
]

{ #category : #converting }
SLVMClosureDefinition >> normalFunctionTypes [
	^ normalFunctionTypes ifNil: [normalFunctionTypes := self closureType normalFunctionTypeWith: compilationTarget]
]

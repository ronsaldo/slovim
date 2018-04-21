Class {
	#name : #LLVMFunction,
	#superclass : #LLVMGlobalObject,
	#instVars : [
		'functionType',
		'basicBlocks',
		'callingConvenction',
		'arguments',
		'symbolGenerationCount',
		'hasArgumentNames'
	],
	#category : #'LLVM-IR'
}

{ #category : #'as yet unclassified' }
LLVMFunction class >> createWithType: functionType linkage: linkage [
	^ self createWithType: functionType linkage: linkage name: nil module: nil
]

{ #category : #'as yet unclassified' }
LLVMFunction class >> createWithType: functionType linkage: linkage name: aName [
	^ self createWithType: functionType linkage: linkage name: aName module: nil
]

{ #category : #'as yet unclassified' }
LLVMFunction class >> createWithType: functionType linkage: linkage name: aName module: module [
	^ self new initializeWithType: functionType linkage: linkage name: aName module: module
]

{ #category : #adding }
LLVMFunction >> addBasicBlock: basicBlock [
	^ self addBasicBlock: basicBlock before: nil
]

{ #category : #adding }
LLVMFunction >> addBasicBlock: basicBlock before: previousBasicBlock [
	self ensureArgumentNames.

	basicBlock parent: self.
	basicBlock name ifNil: [ basicBlock name: self generateSymbol ].
	basicBlocks add: basicBlock

]

{ #category : #accessing }
LLVMFunction >> arguments [
	^ arguments
]

{ #category : #accessing }
LLVMFunction >> basicBlocks [
	^ basicBlocks
]

{ #category : #adding }
LLVMFunction >> ensureArgumentNames [
	hasArgumentNames ifTrue: [ ^ self ].
	hasArgumentNames := true.

	arguments do: [ :arg |
		arg name ifNil: [ arg name: self generateSymbol ]
	].

]

{ #category : #printing }
LLVMFunction >> fullPrintOn: aStream [
	basicBlocks ifEmpty: [
		aStream << 'declare ' << linkage second << ' ' << visibility second << ' ' << dllStorageClass  second << callingConvenction << ' ' <<
		functionType returnType name << ' @' << self name << ' ( '.
		
		arguments doWithIndex: [ :arg :index |
			index > 1 ifTrue: [ aStream << ', ' ].
			arg printOnDeclaration: aStream
		].
		
		aStream << ' )'; lf.
		^ self
	].

	aStream << 'define ' << linkage second << ' ' << visibility second << ' ' << dllStorageClass  second << callingConvenction << ' ' <<
	functionType returnType name << ' @' << self name << ' ( '.
	
	arguments doWithIndex: [ :arg :index |
			index > 1 ifTrue: [ aStream << ', ' ].
			arg printOnDefinition: aStream
	].
	aStream << ' ) {'; lf.
	basicBlocks do: [ :bb | bb fullPrintOn: aStream ].
	aStream << '}'; lf.

	
]

{ #category : #initialization }
LLVMFunction >> generateSymbol [
	| result |
	result := symbolGenerationCount asString.
	symbolGenerationCount := symbolGenerationCount + 1.
	^ result
]

{ #category : #accessing }
LLVMFunction >> hasArgumentNames [
	^ hasArgumentNames
]

{ #category : #initialization }
LLVMFunction >> initialize [
	super initialize.
	basicBlocks := OrderedCollection new.
	callingConvenction := #ccc.
	symbolGenerationCount := 0.
	hasArgumentNames := false.
	
]

{ #category : #initialization }
LLVMFunction >> initializeWithType: theFunctionType linkage: theLinkage name: theName module: theModule [
	self assert: theFunctionType isFunctionTy.
	functionType := theFunctionType.
	self linkage: theLinkage.
	self name: theName.
	self type: (LLVMPointerType getUnqual: functionType).
	theModule ifNotNil: [
		theModule addGlobalValue: self
	].

	arguments := functionType params collectWithIndex: [ :param :index |
		LLVMArgument new
			parent: self;
			argNo: index - 1;
			type: param;
			yourself
	].

]

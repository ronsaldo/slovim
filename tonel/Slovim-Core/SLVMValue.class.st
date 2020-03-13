"
I represent a value in SSA form.
"
Class {
	#name : #SLVMValue,
	#superclass : #SLVMObject,
	#instVars : [
		'flags'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMValue class >> mnemonic [
	^ self subclassResponsibility
]

{ #category : #printing }
SLVMValue class >> mnemonics [
	^ {self mnemonic}
]

{ #category : #visitor }
SLVMValue >> accept: aVisitor [
	self subclassResponsibility
]

{ #category : #flags }
SLVMValue >> addFlag: aFlag [
	flags := (self flags copyWithout: aFlag) copyWith: aFlag
]

{ #category : #adding }
SLVMValue >> addInstructionReference: anInstruction [
	"By default, do nothing"
]

{ #category : #converting }
SLVMValue >> asCanonicalLocalReference [
	^ self
]

{ #category : #printing }
SLVMValue >> asFullSExpression [
	^ self asSExpression
]

{ #category : #printing }
SLVMValue >> asSExpression [
	self subclassResponsibility
]

{ #category : #accessing }
SLVMValue >> childrenNodes [
	^ #()
]

{ #category : #flags }
SLVMValue >> flags [
	^ flags ifNil: [ #() ]
]

{ #category : #flags }
SLVMValue >> flags: newFlags [
	flags := newFlags asArray
]

{ #category : #printing }
SLVMValue >> fullPrintOn: aStream [
	self printOn: aStream
]

{ #category : #printing }
SLVMValue >> fullPrintString [
	^ SLVMPrintingStream fullPrintString: self
]

{ #category : #printing }
SLVMValue >> fullPrintText [
	^ SLVMPrintingTextStream fullPrintString: self
]

{ #category : #flags }
SLVMValue >> hasFlag: aFlag [
	^ self flags includes: aFlag
]

{ #category : #testing }
SLVMValue >> isClosureCapture [
	^ false
]

{ #category : #testing }
SLVMValue >> isClosureDefinition [
	^ false
]

{ #category : #testing }
SLVMValue >> isConstant [
	^ false
]

{ #category : #testing }
SLVMValue >> isConstantAggregateValue [
	^ false
]

{ #category : #testing }
SLVMValue >> isConstantArrayBlob [
	^ false
]

{ #category : #testing }
SLVMValue >> isConstantArrayValue [
	^ false
]

{ #category : #testing }
SLVMValue >> isConstantBuiltInFunction [
	^ false
]

{ #category : #testing }
SLVMValue >> isConstantExpressionBitCast [
	^ false
]

{ #category : #testing }
SLVMValue >> isConstantMatrixValue [
	^ false
]

{ #category : #testing }
SLVMValue >> isConstantPointer [
	^ false
]

{ #category : #testing }
SLVMValue >> isConstantStructureValue [
	^ false
]

{ #category : #testing }
SLVMValue >> isConstantValue [
	^ false
]

{ #category : #testing }
SLVMValue >> isConstantVectorValue [
	^ false
]

{ #category : #testing }
SLVMValue >> isFakeValue [
	^ false
]

{ #category : #testing }
SLVMValue >> isFunction [
	^ false
]

{ #category : #testing }
SLVMValue >> isFunctionArgument [
	^ false
]

{ #category : #testing }
SLVMValue >> isFunctionExitPoint [
	^ false
]

{ #category : #testing }
SLVMValue >> isFunctionLocalValue [
	^ false
]

{ #category : #testing }
SLVMValue >> isGlobalValue [
	^ false
]

{ #category : #testing }
SLVMValue >> isGlobalVariable [
	^ false
]

{ #category : #testing }
SLVMValue >> isInstruction [
	^ false
]

{ #category : #testing }
SLVMValue >> isOneConstant [
	^ false
]

{ #category : #testing }
SLVMValue >> isPhi [
	^ false
]

{ #category : #testing }
SLVMValue >> isPureFunction [
	^ false
]

{ #category : #testing }
SLVMValue >> isSSAValue [
	^ true
]

{ #category : #testing }
SLVMValue >> isUnaryOperation [
	^ false
]

{ #category : #testing }
SLVMValue >> isUndefined [
	^ false
]

{ #category : #testing }
SLVMValue >> isZeroConstant [
	^ false
]

{ #category : #accessing }
SLVMValue >> livenessIndex [
	^ nil
]

{ #category : #printing }
SLVMValue >> mnemonic [
	^ self class mnemonic
]

{ #category : #'as yet unclassified' }
SLVMValue >> nodeTitle [
	^ self printString
]

{ #category : #accessing }
SLVMValue >> notVisitedParameters: visitedElements recursivelyDo: aBlock [
]

{ #category : #flags }
SLVMValue >> removeFlag: flag [
	self flags ifEmpty: [ ^ self ].
	flags := flags copyWithout: flag.
]

{ #category : #adding }
SLVMValue >> removeInstructionReference: anInstruction [
	"By default, do nothing"
]

{ #category : #flags }
SLVMValue >> setFlag: flag value: newValue [
	newValue ifTrue: [
		self addFlag: flag
	] ifFalse: [
		self removeFlag: flag
	]
]

{ #category : #accessing }
SLVMValue >> type [
	self subclassResponsibility
]

Class {
	#name : #SLVMValue,
	#superclass : #SLVMObject,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visitor }
SLVMValue >> accept: aVisitor [
	self subclassResponsibility
]

{ #category : #adding }
SLVMValue >> addInstructionReference: anInstruction [
	"By default, do nothing"
]

{ #category : #accessing }
SLVMValue >> childrenNodes [
	^ #()
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
SLVMValue >> isConstantBuiltInFunction [
	^ false
]

{ #category : #testing }
SLVMValue >> isConstantPointer [
	^ false
]

{ #category : #testing }
SLVMValue >> isConstantValue [
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
SLVMValue >> isInstruction [
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

{ #category : #accessing }
SLVMValue >> livenessIndex [
	^ nil
]

{ #category : #'as yet unclassified' }
SLVMValue >> nodeTitle [
	^ self printString
]

{ #category : #adding }
SLVMValue >> removeInstructionReference: anInstruction [
	"By default, do nothing"
]

{ #category : #accessing }
SLVMValue >> type [
	self subclassResponsibility
]

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

{ #category : #printing }
SLVMValue >> fullPrintOn: aStream [
	self printOn: aStream
]

{ #category : #printing }
SLVMValue >> fullPrintString [
	^ ByteString streamContents: [ :out | self fullPrintOn: out ]
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
SLVMValue >> isConstantValue [
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
SLVMValue >> isUndefined [
	^ false
]

{ #category : #adding }
SLVMValue >> removeInstructionReference: anInstruction [
	"By default, do nothing"
]

{ #category : #accessing }
SLVMValue >> type [
	self subclassResponsibility
]

Class {
	#name : #SLVMLirX86Register,
	#superclass : #SLVMLirInstructionOperand,
	#instVars : [
		'name',
		'value'
	],
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMLirX86Register class >> canHoldValueOfType: aValue [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SLVMLirX86Register >> encodeModRMWithOpcode: opcode immediate: immediateSizee longMode: longMod into: writer [
	| mod |
	mod := 3.
	writer put: (mod << 6) | (opcode << 3) | self valueLow
]

{ #category : #accessing }
SLVMLirX86Register >> isHighRegister [
	^ value > 7
]

{ #category : #accessing }
SLVMLirX86Register >> isLowRegister [
	^ value <= 7
]

{ #category : #testing }
SLVMLirX86Register >> isRegister [
	^ true
]

{ #category : #testing }
SLVMLirX86Register >> isVectorRegister [
	^ false
]

{ #category : #accessing }
SLVMLirX86Register >> name [
	^ name
]

{ #category : #accessing }
SLVMLirX86Register >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMLirX86Register >> printOn: aStream [
	aStream nextPutAll: name
]

{ #category : #accessing }
SLVMLirX86Register >> size [
	^ self subclassResponsibility
]

{ #category : #accessing }
SLVMLirX86Register >> value [
	^ value
]

{ #category : #accessing }
SLVMLirX86Register >> value: anObject [
	value := anObject
]

{ #category : #accessing }
SLVMLirX86Register >> valueLow [
	^ value bitAnd: 7
]

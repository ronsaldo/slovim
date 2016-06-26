Class {
	#name : #SLVMStoreInstruction,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMStoreInstruction class >> value: value variable: variable [
	^ self new value: value variable: variable
]

{ #category : #visitor }
SLVMStoreInstruction >> accept: aVisitor [
	^ aVisitor visitStore: self
]

{ #category : #testing }
SLVMStoreInstruction >> hasOutputs [
	^ false
]

{ #category : #testing }
SLVMStoreInstruction >> isStore [
	^ true
]

{ #category : #printing }
SLVMStoreInstruction >> mnemonic [
	^ 'store'
]

{ #category : #accessing }
SLVMStoreInstruction >> type [
	^ SLVMType voidType
]

{ #category : #accessing }
SLVMStoreInstruction >> value [
	^ parameters first
]

{ #category : #construction }
SLVMStoreInstruction >> value: value variable: variable [
	self parameters: { value . variable }
]

{ #category : #accessing }
SLVMStoreInstruction >> variable [
	^ parameters second
]

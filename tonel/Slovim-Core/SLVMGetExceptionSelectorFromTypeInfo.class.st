Class {
	#name : #SLVMGetExceptionSelectorFromTypeInfo,
	#superclass : #SLVMInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMGetExceptionSelectorFromTypeInfo class >> mnemonic [
	^ #getExceptionSelectorFromTypeInfo
]

{ #category : #'as yet unclassified' }
SLVMGetExceptionSelectorFromTypeInfo class >> typeInfoPointer: aPointer [
	^ self new typeInfoPointer: aPointer
]

{ #category : #visitor }
SLVMGetExceptionSelectorFromTypeInfo >> accept: aVisitor [
	^ aVisitor visitGetExceptionSelectorFromTypeInfo: self
]

{ #category : #testing }
SLVMGetExceptionSelectorFromTypeInfo >> isGetExceptionSelectorFromTypeInfo [
	^ true
]

{ #category : #accessing }
SLVMGetExceptionSelectorFromTypeInfo >> type [
	^ SLVMType intType
]

{ #category : #'as yet unclassified' }
SLVMGetExceptionSelectorFromTypeInfo >> typeInfoPointer [
	^ parameters first
]

{ #category : #'as yet unclassified' }
SLVMGetExceptionSelectorFromTypeInfo >> typeInfoPointer: aPointer [
	self parameters: { aPointer }
]

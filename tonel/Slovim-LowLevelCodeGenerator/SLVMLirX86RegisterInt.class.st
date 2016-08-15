Class {
	#name : #SLVMLirX86RegisterInt,
	#superclass : #SLVMLirX86Register,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #converting }
SLVMLirX86RegisterInt >> asX86Ptr [
	^ SLVMLirX86RegisterAddress new base: self; size: self size
]

{ #category : #converting }
SLVMLirX86RegisterInt >> asX86PtrOfSize: ptrSize [
	^ SLVMLirX86RegisterAddress new base: self; size: ptrSize
]

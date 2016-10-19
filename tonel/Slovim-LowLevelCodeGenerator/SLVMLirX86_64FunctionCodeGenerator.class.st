Class {
	#name : #'SLVMLirX86_64FunctionCodeGenerator',
	#superclass : #SLVMLirX86FunctionCodeGenerator,
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #initialization }
SLVMLirX86_64FunctionCodeGenerator >> initialize [
	super initialize.
	longMode := true.
]

{ #category : #accessing }
SLVMLirX86_64FunctionCodeGenerator >> stackArgumentAlignment [
	^ 8
]

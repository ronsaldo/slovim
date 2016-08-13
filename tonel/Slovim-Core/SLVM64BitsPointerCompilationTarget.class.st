Class {
	#name : #SLVM64BitsPointerCompilationTarget,
	#superclass : #SLVMCompilationTarget,
	#category : #'Slovim-Core-Type'
}

{ #category : #accessing }
SLVM64BitsPointerCompilationTarget >> pointerAlignment [
	^ 8
]

{ #category : #accessing }
SLVM64BitsPointerCompilationTarget >> pointerSize [
	^ 8
]

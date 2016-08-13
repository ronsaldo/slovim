Class {
	#name : #SLVM32BitsPointerCompilationTarget,
	#superclass : #SLVMCompilationTarget,
	#category : #'Slovim-Core-Type'
}

{ #category : #accessing }
SLVM32BitsPointerCompilationTarget >> pointerAlignment [
	^ 4
]

{ #category : #accessing }
SLVM32BitsPointerCompilationTarget >> pointerSize [
	^ 4
]

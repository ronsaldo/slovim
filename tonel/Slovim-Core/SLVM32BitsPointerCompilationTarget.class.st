Class {
	#name : #SLVM32BitsPointerCompilationTarget,
	#superclass : #SLVMCompilationTarget,
	#category : #'Slovim-Core-Type'
}

{ #category : #accessing }
SLVM32BitsPointerCompilationTarget >> canonicalName [
	^ #'generic-32'
]

{ #category : #types }
SLVM32BitsPointerCompilationTarget >> double [
	^ self doubleAlign4
]

{ #category : #accessing }
SLVM32BitsPointerCompilationTarget >> pointerAlignment [
	^ 4
]

{ #category : #accessing }
SLVM32BitsPointerCompilationTarget >> pointerSize [
	^ 4
]

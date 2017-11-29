Class {
	#name : #SLVM32BitsPointerCompilationTarget,
	#superclass : #SLVMCompilationTarget,
	#category : #'Slovim-Core-Type'
}

{ #category : #accessing }
SLVM32BitsPointerCompilationTarget >> canonicalName [
	^ #'generic-32'
]

{ #category : #initialization }
SLVM32BitsPointerCompilationTarget >> createTargetTypes [
	^ SLVM32BitsPointerCompilationTargetTypes new
]

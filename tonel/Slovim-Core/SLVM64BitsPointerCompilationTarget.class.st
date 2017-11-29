Class {
	#name : #SLVM64BitsPointerCompilationTarget,
	#superclass : #SLVMCompilationTarget,
	#category : #'Slovim-Core-Type'
}

{ #category : #accessing }
SLVM64BitsPointerCompilationTarget >> canonicalName [
	^ #'generic-64'
]

{ #category : #initialization }
SLVM64BitsPointerCompilationTarget >> createTargetTypes [
	^ SLVM64BitsPointerCompilationTargetTypes new
]

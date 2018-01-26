Class {
	#name : #SLVM32BitsPointerCompilationTargetTypes,
	#superclass : #SLVMCompilationTargetTypes,
	#category : #'Slovim-Core-Type'
}

{ #category : #types }
SLVM32BitsPointerCompilationTargetTypes >> double [
	^ self doubleAlign4
]

{ #category : #accessing }
SLVM32BitsPointerCompilationTargetTypes >> pointerAlignment [
	^ 4
]

{ #category : #accessing }
SLVM32BitsPointerCompilationTargetTypes >> pointerSize [
	^ 4
]
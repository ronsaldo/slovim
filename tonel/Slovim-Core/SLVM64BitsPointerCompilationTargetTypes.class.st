Class {
	#name : #SLVM64BitsPointerCompilationTargetTypes,
	#superclass : #SLVMCompilationTargetTypes,
	#category : #'Slovim-Core-Type'
}

{ #category : #types }
SLVM64BitsPointerCompilationTargetTypes >> double [
	^ SLVMType doubleAlign8Type
]

{ #category : #accessing }
SLVM64BitsPointerCompilationTargetTypes >> intPointer [
	^ self int64
]

{ #category : #accessing }
SLVM64BitsPointerCompilationTargetTypes >> pointerAlignment [
	^ 8
]

{ #category : #accessing }
SLVM64BitsPointerCompilationTargetTypes >> pointerSize [
	^ 8
]

{ #category : #accessing }
SLVM64BitsPointerCompilationTargetTypes >> uintPointer [
	^ self uint64
]

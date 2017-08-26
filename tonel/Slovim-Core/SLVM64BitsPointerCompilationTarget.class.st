Class {
	#name : #SLVM64BitsPointerCompilationTarget,
	#superclass : #SLVMCompilationTarget,
	#category : #'Slovim-Core-Type'
}

{ #category : #accessing }
SLVM64BitsPointerCompilationTarget >> canonicalName [
	^ #'generic-64'
]

{ #category : #types }
SLVM64BitsPointerCompilationTarget >> double [
	^ SLVMType doubleAlign8Type
]

{ #category : #accessing }
SLVM64BitsPointerCompilationTarget >> pointerAlignment [
	^ 8
]

{ #category : #accessing }
SLVM64BitsPointerCompilationTarget >> pointerSize [
	^ 8
]

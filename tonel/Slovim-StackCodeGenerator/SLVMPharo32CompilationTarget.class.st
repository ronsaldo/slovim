Class {
	#name : #SLVMPharo32CompilationTarget,
	#superclass : #SLVM32BitsPointerCompilationTarget,
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #convenience }
SLVMPharo32CompilationTarget >> generateLowLevelModule: aModule [
	^ SLVMStackCodeGenerator new target: self; translateModule: aModule
]

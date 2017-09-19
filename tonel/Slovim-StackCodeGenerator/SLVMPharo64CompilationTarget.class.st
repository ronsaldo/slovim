Class {
	#name : #SLVMPharo64CompilationTarget,
	#superclass : #SLVM64BitsPointerCompilationTarget,
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #convenience }
SLVMPharo64CompilationTarget >> generateLowLevelModule: aModule [
	^ SLVMStackCodeGenerator new target: self; translateModule: aModule
]

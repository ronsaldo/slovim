Class {
	#name : #SLVMPharo64CompilationTarget,
	#superclass : #SLVM64BitsPointerCompilationTarget,
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #'as yet unclassified' }
SLVMPharo64CompilationTarget >> finalTargetCodeGeneratorClass [
	^ SLVMPharoCodeGenerator
]

{ #category : #convenience }
SLVMPharo64CompilationTarget >> generateLowLevelModule: aModule [
	^ SLVMStackCodeGenerator new target: self; translateModule: aModule
]

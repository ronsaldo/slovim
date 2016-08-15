Class {
	#name : #'SLVMLirX86_64CodeGenerator',
	#superclass : #SLVMLirCodeGenerator,
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMLirX86_64CodeGenerator >> initialize [
	super initialize.
	compilationTarget := SLVMX86_64CompilationTarget new.
	functionCodeGeneratorClass := SLVMLirX86_64FunctionCodeGenerator.
]

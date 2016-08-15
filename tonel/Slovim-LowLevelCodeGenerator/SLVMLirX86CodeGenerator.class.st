Class {
	#name : #SLVMLirX86CodeGenerator,
	#superclass : #SLVMLirCodeGenerator,
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #initialization }
SLVMLirX86CodeGenerator >> initialize [
	super initialize.
	compilationTarget := SLVMX86CompilationTarget new.
	functionCodeGeneratorClass := SLVMLirX86FunctionCodeGenerator.
]

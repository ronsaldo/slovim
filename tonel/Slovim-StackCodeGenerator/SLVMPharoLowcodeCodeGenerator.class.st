"
I am a code generator for a Pharo image with support for Lowcode.
"
Class {
	#name : #SLVMPharoLowcodeCodeGenerator,
	#superclass : #SLVMPharoCodeGenerator,
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #'as yet unclassified' }
SLVMPharoLowcodeCodeGenerator >> functionCodeGeneratorClass [
	^ SLVMPharoLowcodeFunctionCodeGenerator
]

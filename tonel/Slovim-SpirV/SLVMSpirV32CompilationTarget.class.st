Class {
	#name : #SLVMSpirV32CompilationTarget,
	#superclass : #SLVM32BitsPointerCompilationTarget,
	#instVars : [
		'logicalAddressMode'
	],
	#category : #'Slovim-SpirV'
}

{ #category : #convenience }
SLVMSpirV32CompilationTarget >> generateLowLevelModule: aModule [
	^ self generateLowLevelModule: aModule optimizationLevel: 0
]

{ #category : #convenience }
SLVMSpirV32CompilationTarget >> generateLowLevelModule: aModule optimizationLevel: anOptimizationLevel [
	^ SLVMSpirVCodeGenerator new
		target: self;
		logicalAddressMode: logicalAddressMode;
		optimizationLevel: anOptimizationLevel;
		translateModule: aModule
]

{ #category : #testing }
SLVMSpirV32CompilationTarget >> isGPU [
	^ true
]

{ #category : #testing }
SLVMSpirV32CompilationTarget >> isMultiSpirV [
	^ false
]

{ #category : #testing }
SLVMSpirV32CompilationTarget >> isSpirV [
	^ true
]

{ #category : #accessing }
SLVMSpirV32CompilationTarget >> logicalAddressMode [
	^ logicalAddressMode
]

{ #category : #accessing }
SLVMSpirV32CompilationTarget >> logicalAddressMode: anObject [
	logicalAddressMode := anObject
]

{ #category : #accessing }
SLVMSpirV32CompilationTarget >> lowLevelCodeGeneratorClass [
	^ SLVMSpirVCodeGenerator
]

{ #category : #accessing }
SLVMSpirV32CompilationTarget >> operatingSystemName [
	^ #gpu
]

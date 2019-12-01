Class {
	#name : #SLVMSpirV64CompilationTarget,
	#superclass : #SLVM64BitsPointerCompilationTarget,
	#instVars : [
		'logicalAddressMode'
	],
	#category : #'Slovim-SpirV'
}

{ #category : #convenience }
SLVMSpirV64CompilationTarget >> generateLowLevelModule: aModule [
	^ self generateLowLevelModule: aModule optimizationLevel: 0
]

{ #category : #convenience }
SLVMSpirV64CompilationTarget >> generateLowLevelModule: aModule optimizationLevel: anOptimizationLevel [
	^ SLVMSpirVCodeGenerator new
		target: self;
		logicalAddressMode: logicalAddressMode;
		optimizationLevel: anOptimizationLevel;
		translateModule: aModule
]

{ #category : #testing }
SLVMSpirV64CompilationTarget >> isGPU [
	^ true
]

{ #category : #testing }
SLVMSpirV64CompilationTarget >> isSpirV [
	^ true
]

{ #category : #accessing }
SLVMSpirV64CompilationTarget >> logicalAddressMode [
	^ logicalAddressMode
]

{ #category : #accessing }
SLVMSpirV64CompilationTarget >> logicalAddressMode: anObject [
	logicalAddressMode := anObject
]

{ #category : #accessing }
SLVMSpirV64CompilationTarget >> lowLevelCodeGeneratorClass [
	^ SLVMSpirVCodeGenerator new logicalAddressMode: logicalAddressMode
]

{ #category : #accessing }
SLVMSpirV64CompilationTarget >> operatingSystemName [
	^ #gpu
]

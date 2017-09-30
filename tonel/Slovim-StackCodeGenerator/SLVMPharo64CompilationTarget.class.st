Class {
	#name : #SLVMPharo64CompilationTarget,
	#superclass : #SLVM64BitsPointerCompilationTarget,
	#instVars : [
		'currentImage'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #convenience }
SLVMPharo64CompilationTarget >> createCodeGenerator [
	^ SLVMStackCodeGenerator new target: self
]

{ #category : #accessing }
SLVMPharo64CompilationTarget >> currentImage [
	^ currentImage
]

{ #category : #accessing }
SLVMPharo64CompilationTarget >> currentImage: anObject [
	currentImage := anObject
]

{ #category : #'as yet unclassified' }
SLVMPharo64CompilationTarget >> finalTargetCodeGeneratorClass [
	^ SLVMPharoCodeGenerator
]

{ #category : #convenience }
SLVMPharo64CompilationTarget >> generateLowLevelModule: aModule [
	^ self createCodeGenerator translateModule: aModule
]

{ #category : #initialization }
SLVMPharo64CompilationTarget >> initialize [
	super initialize.
	currentImage := false.
	
]

{ #category : #testing }
SLVMPharo64CompilationTarget >> isCurrentImage [
	^ currentImage
]

Class {
	#name : #SLVMPharo32CompilationTarget,
	#superclass : #SLVM32BitsPointerCompilationTarget,
	#instVars : [
		'currentImage'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #convenience }
SLVMPharo32CompilationTarget >> createCodeGenerator [
	^ SLVMStackCodeGenerator new target: self
]

{ #category : #accessing }
SLVMPharo32CompilationTarget >> currentImage [
	^ currentImage
]

{ #category : #accessing }
SLVMPharo32CompilationTarget >> currentImage: anObject [
	currentImage := anObject
]

{ #category : #'as yet unclassified' }
SLVMPharo32CompilationTarget >> finalTargetCodeGeneratorClass [
	^ SLVMPharoCodeGenerator
]

{ #category : #convenience }
SLVMPharo32CompilationTarget >> generateLowLevelModule: aModule [
	^ self createCodeGenerator translateModule: aModule
]

{ #category : #initialization }
SLVMPharo32CompilationTarget >> initialize [
	super initialize.
	currentImage := false.
	
]

{ #category : #testing }
SLVMPharo32CompilationTarget >> isCurrentImage [
	^ currentImage
]

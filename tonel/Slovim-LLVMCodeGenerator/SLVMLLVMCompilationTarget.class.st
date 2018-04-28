Class {
	#name : #SLVMLLVMCompilationTarget,
	#superclass : #SLVMCompilationTarget,
	#instVars : [
		'architecture',
		'pointerSize'
	],
	#category : #'Slovim-LLVMCodeGenerator'
}

{ #category : #construction }
SLVMLLVMCompilationTarget class >> x86 [
	^ self basicNew
		architecture: #x86;
		pointerSize: 4;
		initialize;
		yourself
]

{ #category : #construction }
SLVMLLVMCompilationTarget class >> x86_64 [
	^ self basicNew
		architecture: #x86_64;
		pointerSize: 8;
		initialize;
		yourself
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> architecture [
	^ architecture
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> architecture: anObject [
	architecture := anObject
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> createTargetTypes [
	^ pointerSize = 4
		ifTrue: [ SLVM32BitsPointerCompilationTargetTypes new ]
		ifFalse: [ SLVM64BitsPointerCompilationTargetTypes new ]
]

{ #category : #convenience }
SLVMLLVMCompilationTarget >> generateLowLevelModule: aModule [
	^ SLVMLLVMCodeGenerator new target: self; translateModule: aModule
]

{ #category : #convenience }
SLVMLLVMCompilationTarget >> generateLowLevelModule: aModule optimizationLevel: anOptimizationLevel [
	^ SLVMLLVMCodeGenerator new
		target: self;
		optimizationLevel: anOptimizationLevel;
		translateModule: aModule
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> pointerSize [
	^ pointerSize
]

{ #category : #accessing }
SLVMLLVMCompilationTarget >> pointerSize: anObject [
	pointerSize := anObject
]

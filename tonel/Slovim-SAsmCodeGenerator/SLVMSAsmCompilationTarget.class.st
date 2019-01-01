"
I represent a generic SAsm compilation target.
"
Class {
	#name : #SLVMSAsmCompilationTarget,
	#superclass : #SLVMCompilationTarget,
	#instVars : [
		'target'
	],
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #construction }
SLVMSAsmCompilationTarget class >> forTarget: aSAsmCompilationTarget [
	^ self basicNew target: aSAsmCompilationTarget; initialize.
]

{ #category : #construction }
SLVMSAsmCompilationTarget class >> x86 [
	^ self forTarget: SAsmCompilationTargetX86 new
]

{ #category : #construction }
SLVMSAsmCompilationTarget class >> x86_64 [
	^ self forTarget: SAsmCompilationTargetX86_64 new
]

{ #category : #accessing }
SLVMSAsmCompilationTarget >> cFunctionPrefix [
	^ target cFunctionPrefix
]

{ #category : #accessing }
SLVMSAsmCompilationTarget >> cVariablePrefix [
	^ target cVariablePrefix
]

{ #category : #accessing }
SLVMSAsmCompilationTarget >> canonicalName [
	^ target canonicalName
]

{ #category : #initialization }
SLVMSAsmCompilationTarget >> createTargetTypes [
	^ SLVMSAsmCompilationTargetTypes new target: target
]

{ #category : #'operating systems' }
SLVMSAsmCompilationTarget >> freebsd [
	target freebsd
]

{ #category : #convenience }
SLVMSAsmCompilationTarget >> generateLowLevelModule: aModule [
	^ SLVMSAsmCodeGenerator new target: self; translateModule: aModule
]

{ #category : #convenience }
SLVMSAsmCompilationTarget >> generateLowLevelModule: aModule optimizationLevel: anOptimizationLevel [
	^ SLVMSAsmCodeGenerator new
		target: self;
		optimizationLevel: anOptimizationLevel;
		translateModule: aModule
]

{ #category : #'operating systems' }
SLVMSAsmCompilationTarget >> linux [
	target linux
]

{ #category : #testing }
SLVMSAsmCompilationTarget >> needsSlotForGOTPointer [
	<compileTime>
	^ target needsSlotForGOTPointer
]

{ #category : #accessing }
SLVMSAsmCompilationTarget >> objectModel: anObjectModel [
	target objectModel: (SLVMSAsmObjectModel new target: target; objectModel: anObjectModel).
	super objectModel: anObjectModel
]

{ #category : #accessing }
SLVMSAsmCompilationTarget >> operatingSystemName [
	^ target operatingSystemName
]

{ #category : #'operating systems' }
SLVMSAsmCompilationTarget >> osx [
	target osx
]

{ #category : #'position indepence code' }
SLVMSAsmCompilationTarget >> pic [
	target positionIndependentCode: true; executable: false
]

{ #category : #'position indepence code' }
SLVMSAsmCompilationTarget >> pie [
	target positionIndependentCode: true; executable: true
]

{ #category : #accessing }
SLVMSAsmCompilationTarget >> target [
	^ target
]

{ #category : #accessing }
SLVMSAsmCompilationTarget >> target: anObject [
	target := anObject
]

{ #category : #'operating systems' }
SLVMSAsmCompilationTarget >> win32 [
	target win32
]

{ #category : #'as yet unclassified' }
SLVMSAsmCompilationTarget >> withPositionIndependentCode [
	target withPositionIndependentCode
]

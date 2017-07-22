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
SLVMSAsmCompilationTarget class >> x86 [
	^ self new target: SAsmCompilationTargetX86 new
]

{ #category : #construction }
SLVMSAsmCompilationTarget class >> x86_64 [
	^ self new target: SAsmCompilationTargetX86_64 new
]

{ #category : #accessing }
SLVMSAsmCompilationTarget >> canonicalName [
	^ target canonicalName
]

{ #category : #accessing }
SLVMSAsmCompilationTarget >> csymbolPrefix [
	^ target csymbolPrefix
]

{ #category : #'operating systems' }
SLVMSAsmCompilationTarget >> freebsd [
	target freebsd
]

{ #category : #convenience }
SLVMSAsmCompilationTarget >> generateLowLevelModule: aModule [
	^ SLVMSAsmCodeGenerator new target: self; translateModule: aModule
]

{ #category : #'operating systems' }
SLVMSAsmCompilationTarget >> linux [
	target linux
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

{ #category : #accessing }
SLVMSAsmCompilationTarget >> pointerAlignment [
	^ target pointerAlignment
]

{ #category : #accessing }
SLVMSAsmCompilationTarget >> pointerSize [
	^ target pointerSize
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

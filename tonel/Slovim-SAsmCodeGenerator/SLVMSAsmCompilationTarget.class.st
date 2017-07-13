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

{ #category : #convenience }
SLVMSAsmCompilationTarget >> generateLowLevelModule: aModule [
	^ SLVMSAsmCodeGenerator new target: self; translateModule: aModule
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

{ #category : #'as yet unclassified' }
SLVMSAsmCompilationTarget >> withPositionIndependentCode [
	target withPositionIndependentCode
]

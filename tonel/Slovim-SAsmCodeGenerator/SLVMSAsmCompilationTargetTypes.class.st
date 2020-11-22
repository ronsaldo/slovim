Class {
	#name : #SLVMSAsmCompilationTargetTypes,
	#superclass : #SLVMCompilationTargetTypes,
	#instVars : [
		'target'
	],
	#category : #'Slovim-SAsmCodeGenerator'
}

{ #category : #'operating systems' }
SLVMSAsmCompilationTargetTypes >> double [
	^ self isWindowsFamily ifTrue: [ self doubleAlign8 ] ifFalse: [ self doubleAlign4 ]
]

{ #category : #testing }
SLVMSAsmCompilationTargetTypes >> isWindows [
	^ self operatingSystemName = #windows
]

{ #category : #accessing }
SLVMSAsmCompilationTargetTypes >> operatingSystemName [
	^ target operatingSystemName
]

{ #category : #accessing }
SLVMSAsmCompilationTargetTypes >> pointerAlignment [
	^ target pointerAlignment
]

{ #category : #accessing }
SLVMSAsmCompilationTargetTypes >> pointerSize [
	^ target pointerSize
]

{ #category : #accessing }
SLVMSAsmCompilationTargetTypes >> target [
	^ target
]

{ #category : #accessing }
SLVMSAsmCompilationTargetTypes >> target: anObject [
	target := anObject
]

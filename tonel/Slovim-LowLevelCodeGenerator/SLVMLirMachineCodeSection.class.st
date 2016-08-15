Class {
	#name : #SLVMLirMachineCodeSection,
	#superclass : #SLVMLirBinaryFileComponent,
	#instVars : [
		'name',
		'base',
		'code'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #comparing }
SLVMLirMachineCodeSection >> = other [
	^ self class = other class and:
	[ base = other base and:
	[ name = other name] ]
]

{ #category : #accessing }
SLVMLirMachineCodeSection >> base [
	^ base
]

{ #category : #accessing }
SLVMLirMachineCodeSection >> base: anObject [
	base := anObject
]

{ #category : #accessing }
SLVMLirMachineCodeSection >> code [
	^ code
]

{ #category : #accessing }
SLVMLirMachineCodeSection >> code: anObject [
	code := anObject
]

{ #category : #initialization }
SLVMLirMachineCodeSection >> initialize [
	super initialize.
	base := 0.
]

{ #category : #accessing }
SLVMLirMachineCodeSection >> name [
	^ name
]

{ #category : #accessing }
SLVMLirMachineCodeSection >> name: anObject [
	name := anObject
]

{ #category : #'as yet unclassified' }
SLVMLirMachineCodeSection >> size [
	^ code size
]

{ #category : #'as yet unclassified' }
SLVMLirMachineCodeSection >> writeOn: aStream [
	aStream nextPutAll: code
]

Class {
	#name : #SLVMLirMachineCodeSection,
	#superclass : #SLVMLirBinaryFileComponent,
	#instVars : [
		'name',
		'base',
		'code',
		'relocations'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #comparing }
SLVMLirMachineCodeSection >> = other [
	^ self class = other class and:
	[ base = other base and:
	[ name = other name and:
	[ relocations = other relocations ] ] ]
]

{ #category : #accessing }
SLVMLirMachineCodeSection >> addRelocation: aRelocation [
	relocations add: aRelocation
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
	relocations := OrderedCollection new.
]

{ #category : #accessing }
SLVMLirMachineCodeSection >> name [
	^ name
]

{ #category : #accessing }
SLVMLirMachineCodeSection >> name: anObject [
	name := anObject
]

{ #category : #accessing }
SLVMLirMachineCodeSection >> relocations [
	^ relocations
]

{ #category : #accessing }
SLVMLirMachineCodeSection >> size [
	^ code size
]

{ #category : #writing }
SLVMLirMachineCodeSection >> writeOn: aStream [
	aStream nextPutAll: code
]

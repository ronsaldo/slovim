Class {
	#name : #SLVMLirMachineCodeSymbol,
	#superclass : #Object,
	#instVars : [
		'name',
		'position',
		'size',
		'section',
		'visibility',
		'usedForReloc',
		'type'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #comparing }
SLVMLirMachineCodeSymbol >> = other [
	^ self class = other class and:
	[ position = other position and:
	[ ((section isNil and: [other section isNil]) or: [ section name = other section name ]) and:
	[ usedForReloc = other usedForReloc and:
	[ visibility = other visibility ] ] ] ]
]

{ #category : #initialization }
SLVMLirMachineCodeSymbol >> initialize [
	super initialize.
	usedForReloc := false.
	size := 0.
]

{ #category : #testing }
SLVMLirMachineCodeSymbol >> isPrivate [
	^ visibility == #private
]

{ #category : #testing }
SLVMLirMachineCodeSymbol >> isPublic [
	^ visibility == #public
]

{ #category : #testing }
SLVMLirMachineCodeSymbol >> isWeak [
	^ visibility == #weak
]

{ #category : #accessing }
SLVMLirMachineCodeSymbol >> name [
	^ name
]

{ #category : #accessing }
SLVMLirMachineCodeSymbol >> name: anObject [
	name := anObject
]

{ #category : #accessing }
SLVMLirMachineCodeSymbol >> position [
	^ position
]

{ #category : #accessing }
SLVMLirMachineCodeSymbol >> position: anObject [
	position := anObject
]

{ #category : #accessing }
SLVMLirMachineCodeSymbol >> section [
	^ section
]

{ #category : #accessing }
SLVMLirMachineCodeSymbol >> section: anObject [
	section := anObject
]

{ #category : #initialization }
SLVMLirMachineCodeSymbol >> shouldBeKeep [
	^ self isPublic or: [ usedForReloc ]
]

{ #category : #accessing }
SLVMLirMachineCodeSymbol >> size [
	^ size
]

{ #category : #accessing }
SLVMLirMachineCodeSymbol >> size: anObject [
	size := anObject
]

{ #category : #accessing }
SLVMLirMachineCodeSymbol >> type [
	^ type
]

{ #category : #accessing }
SLVMLirMachineCodeSymbol >> type: anObject [
	type := anObject
]

{ #category : #accessing }
SLVMLirMachineCodeSymbol >> usedForReloc [
	^ usedForReloc
]

{ #category : #accessing }
SLVMLirMachineCodeSymbol >> usedForReloc: anObject [
	usedForReloc := anObject
]

{ #category : #accessing }
SLVMLirMachineCodeSymbol >> visibility [
	^ visibility
]

{ #category : #accessing }
SLVMLirMachineCodeSymbol >> visibility: anObject [
	visibility := anObject
]

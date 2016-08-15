Class {
	#name : #SLVMLirMachineCodeRelocation,
	#superclass : #Object,
	#instVars : [
		'offset',
		'addend',
		'symbol',
		'type'
	],
	#classVars : [
		'AbsoluteOffset16',
		'AbsoluteOffset32',
		'AbsoluteOffset64',
		'AbsoluteOffset8',
		'RelativeSOffset16',
		'RelativeSOffset32',
		'RelativeSOffset64',
		'RelativeSOffset8'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #'as yet unclassified' }
SLVMLirMachineCodeRelocation class >> initialize [
	super initialize.
	
	AbsoluteOffset8 := #'absolute-offset8'.
	AbsoluteOffset16 := #'absolute-offset16'.
	AbsoluteOffset32 := #'absolute-offset32'.
	AbsoluteOffset64 := #'absolute-offset32'.
	
	RelativeSOffset8 := #'relative-soffset8'.
	RelativeSOffset16 := #'relative-soffset16'.
	RelativeSOffset32 := #'relative-soffset32'.
	RelativeSOffset64 := #'relative-soffset64'.
]

{ #category : #'as yet unclassified' }
SLVMLirMachineCodeRelocation >> = other [
	^ self class == other class and:
	[ type == other type and:
	[ offset = other offset and:
	[ addend = other addend and:
	[ symbol = other symbol ] ] ] ]
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> absoluteOffset16 [
	type := AbsoluteOffset16
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> absoluteOffset32 [
	type := AbsoluteOffset32
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> absoluteOffset64 [
	type := AbsoluteOffset64
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> absoluteOffset8 [
	type := AbsoluteOffset8
]

{ #category : #accessing }
SLVMLirMachineCodeRelocation >> addend [
	^ addend
]

{ #category : #accessing }
SLVMLirMachineCodeRelocation >> addend: anObject [
	addend := anObject
]

{ #category : #initialization }
SLVMLirMachineCodeRelocation >> initialize [
	super initialize.
	type := AbsoluteOffset32.
	offset := 0.
	addend := 0.
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> isAbsoluteOffset16 [
	^ type == AbsoluteOffset16
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> isAbsoluteOffset32 [
	^ type == AbsoluteOffset32
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> isAbsoluteOffset64 [
	^ type == AbsoluteOffset64
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> isAbsoluteOffset8 [
	^ type == AbsoluteOffset8
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> isRelativeSOffset16 [
	^ type == RelativeSOffset16
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> isRelativeSOffset32 [
	^ type == RelativeSOffset32
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> isRelativeSOffset64 [
	^ type == RelativeSOffset64
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> isRelativeSOffset8 [
	^ type == RelativeSOffset8
]

{ #category : #accessing }
SLVMLirMachineCodeRelocation >> offset [
	^ offset
]

{ #category : #accessing }
SLVMLirMachineCodeRelocation >> offset: anObject [
	offset := anObject
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> relativeSOffset16 [
	type := RelativeSOffset16
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> relativeSOffset32 [
	type := RelativeSOffset32
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> relativeSOffset64 [
	type := RelativeSOffset64
]

{ #category : #testing }
SLVMLirMachineCodeRelocation >> relativeSOffset8 [
	type := RelativeSOffset8
]

{ #category : #accessing }
SLVMLirMachineCodeRelocation >> symbol [
	^ symbol
]

{ #category : #accessing }
SLVMLirMachineCodeRelocation >> symbol: anObject [
	symbol := anObject
]

{ #category : #accessing }
SLVMLirMachineCodeRelocation >> type [
	^ type
]

{ #category : #accessing }
SLVMLirMachineCodeRelocation >> type: anObject [
	type := anObject
]

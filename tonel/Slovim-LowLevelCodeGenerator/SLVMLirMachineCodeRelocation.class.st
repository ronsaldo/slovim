Class {
	#name : #SLVMLirMachineCodeRelocation,
	#superclass : #Object,
	#instVars : [
		'section',
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
	AbsoluteOffset64 := #'absolute-offset64'.
	
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

{ #category : #testing }
SLVMLirMachineCodeRelocation >> absoluteOffsetOfSize: offsetSize [
	offsetSize = 8 ifTrue: [ self absoluteOffset64 ].
	offsetSize = 4 ifTrue: [ self absoluteOffset32 ].
	offsetSize = 2 ifTrue: [ self absoluteOffset16 ].	
	offsetSize = 1 ifTrue: [ self absoluteOffset8 ].	
]

{ #category : #accessing }
SLVMLirMachineCodeRelocation >> addend [
	^ addend
]

{ #category : #accessing }
SLVMLirMachineCodeRelocation >> addend: anObject [
	addend := anObject
]

{ #category : #'as yet unclassified' }
SLVMLirMachineCodeRelocation >> applyImplicitAddend [
	| code |
	self fixAddend = 0 ifTrue: [ ^ 0 ].

	code := section code.
	(self isAbsoluteOffset64 or: [ self isRelativeSOffset64 ]) ifTrue: [ 
		code unsignedLongLongAt: offset + 1 put: (((code unsignedLongLongAt: offset + 1) + addend) bitAnd: 16rFFFFFFFFFFFFFFFF)
	].

	(self isAbsoluteOffset32 or: [ self isRelativeSOffset32 ]) ifTrue: [ 
		code unsignedLongAt: offset + 1 put: (((code unsignedLongAt: offset + 1) + addend) bitAnd: 16rFFFFFFFF)
	].

	addend := 0.
]

{ #category : #'as yet unclassified' }
SLVMLirMachineCodeRelocation >> applyImplicitAddendIn: targetSection [
	| code |
	self fixAddend = 0 ifTrue: [ ^ 0 ].

	code := targetSection code.
	(self isAbsoluteOffset64 or: [ self isRelativeSOffset64 ]) ifTrue: [ 
		code unsignedLongLongAt: offset + 1 put: (((code unsignedLongLongAt: offset + 1) + addend) bitAnd: 16rFFFFFFFFFFFFFFFF)
	].

	(self isAbsoluteOffset32 or: [ self isRelativeSOffset32 ]) ifTrue: [ 
		code unsignedLongAt: offset + 1 put: (((code unsignedLongAt: offset + 1) + addend) bitAnd: 16rFFFFFFFF)
	].

	addend := 0.
]

{ #category : #'as yet unclassified' }
SLVMLirMachineCodeRelocation >> fixAddend [
	addend isInteger ifFalse: [ 
		addend := addend position
	].
	^ addend
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
SLVMLirMachineCodeRelocation >> relativeOffsetOfSize: offsetSize [
	offsetSize = 8 ifTrue: [ self relativeSOffset64 ].
	offsetSize = 4 ifTrue: [ self relativeSOffset32 ].
	offsetSize = 2 ifTrue: [ self relativeSOffset16 ].	
	offsetSize = 1 ifTrue: [ self relativeSOffset8 ].	

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
SLVMLirMachineCodeRelocation >> section [
	^ section
]

{ #category : #accessing }
SLVMLirMachineCodeRelocation >> section: anObject [
	section := anObject
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

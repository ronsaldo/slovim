Class {
	#name : #SLVMLirX86RegisterAddress,
	#superclass : #SLVMLirInstructionOperand,
	#instVars : [
		'size',
		'base',
		'index',
		'scale',
		'displacement'
	],
	#classVars : [
		'ScaleValueMap'
	],
	#pools : [
		'SLVMLirX86Constants'
	],
	#category : #'Slovim-LowLevelCodeGenerator-X86'
}

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterAddress class >> initialize [
	"
	super initialize.
	"
	
	ScaleValueMap := Dictionary newFromPairs: #(
		1 0
		2 1
		4 2
		8 3
	)
]

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterAddress >> + displacementOrIndex [
	| result |
	result := self copy.
	displacementOrIndex isInteger ifTrue: [ ^ self copy displacement: displacementOrIndex ].
	self halt.
]

{ #category : #accessing }
SLVMLirX86RegisterAddress >> base [
	^ base
]

{ #category : #accessing }
SLVMLirX86RegisterAddress >> base: anObject [
	base := anObject
]

{ #category : #accessing }
SLVMLirX86RegisterAddress >> displacement [
	^ displacement
]

{ #category : #accessing }
SLVMLirX86RegisterAddress >> displacement: anObject [
	displacement := anObject
]

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterAddress >> encodeModRMWithOpcode: opcode immediate: immediateSize longMode: longMode into: writer [
	| mod baseValue hasDisplacement hasSmallDisplacement sibByte indexValue scaleValue |
	sibByte := nil.
	self needsSibByte ifTrue: [
		baseValue := base ifNil: [ 5 ] ifNotNil: [ base valueLow ].
		indexValue := index ifNil: [ 4 ] ifNotNil: [ index valueLow ].
		scaleValue := ScaleValueMap at: scale.
		sibByte := (scaleValue << 6) | (indexValue << 3) | baseValue.
	].

	hasDisplacement := false.
	(sibByte isNotNil and: [ base value == EBP value ]) ifTrue: [
		hasDisplacement := true.
		hasSmallDisplacement := self hasSmallDisplacement.
		mod := hasSmallDisplacement ifTrue: [ 1 ] ifFalse: [ 2 ].
	] ifFalse: [
		(displacement = 0 and: [ base value ~~ EBP value ]) ifTrue: [
			mod := 0
		] ifFalse: [
			hasDisplacement := true.
			hasSmallDisplacement := self hasSmallDisplacement.
			mod := hasSmallDisplacement ifTrue: [ 1 ] ifFalse: [ 2 ].
		].
	].

	sibByte ifNotNil: [ 
		baseValue := 4
 	] ifNil: [ 
		base ifNotNil: [
			baseValue := base valueLow.
		] ifNil: [
			hasSmallDisplacement := false.
			self assert: displacement isNotNil.
			baseValue := 5
		].
	].
	
	writer put: (mod << 6) | (opcode << 3) | baseValue.
	sibByte ifNotNil: [ writer put: sibByte ].
	
	hasDisplacement ifTrue: [
		hasSmallDisplacement ifTrue: [
			writer putInt8: displacement
		] ifFalse: [
			writer putMaybeReloc32: displacement
		]
	].

]

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterAddress >> hasSmallDisplacement [
	^ displacement isInteger and: [ displacement between: -128 and: 128 ]
]

{ #category : #accessing }
SLVMLirX86RegisterAddress >> index [
	^ index
]

{ #category : #accessing }
SLVMLirX86RegisterAddress >> index: anObject [
	index := anObject
]

{ #category : #initialization }
SLVMLirX86RegisterAddress >> initialize [
	scale := 1.
	displacement := 0.
]

{ #category : #testing }
SLVMLirX86RegisterAddress >> isRegisterAddress [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMLirX86RegisterAddress >> needsSibByte [
	^ base value == ESP value or: [ scale ~= 1 or: [ index isNotNil ] ]
]

{ #category : #printing }
SLVMLirX86RegisterAddress >> printOn: aStream [
	| hasPrevious |
	aStream nextPut: $[.
	hasPrevious := false.
	base ifNotNil: [.
		aStream print: base.
		hasPrevious := true
	].
	index ifNotNil: [.
		hasPrevious ifTrue: [ aStream nextPutAll: ' + ' ].
		aStream
			print: index; nextPut: $*; print: scale.
		hasPrevious := true
	].
	displacement ~= 0 ifTrue: [.
		hasPrevious ifTrue: [ aStream nextPutAll: ' + ' ].
		aStream
			print: displacement
	].

	aStream nextPut: $].

]

{ #category : #accessing }
SLVMLirX86RegisterAddress >> scale [
	^ scale
]

{ #category : #accessing }
SLVMLirX86RegisterAddress >> scale: anObject [
	scale := anObject
]

{ #category : #accessing }
SLVMLirX86RegisterAddress >> size [
	^ size
]

{ #category : #accessing }
SLVMLirX86RegisterAddress >> size: aSize [
	size := aSize
]

Class {
	#name : #SLVMStringConstantValue,
	#superclass : #SLVMConstantValue,
	#instVars : [
		'hasExtraNullCharacter'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'as yet unclassified' }
SLVMStringConstantValue >> asBlob [
	^ ByteArray streamContents: [ :out |
		value do: [ :char | out nextPut: char asInteger ].
		hasExtraNullCharacter ifTrue: [
			out nextPut: 0
		]
	]
]

{ #category : #accessing }
SLVMStringConstantValue >> hasExtraNullCharacter [
	^ hasExtraNullCharacter
]

{ #category : #accessing }
SLVMStringConstantValue >> hasExtraNullCharacter: anObject [
	hasExtraNullCharacter := anObject
]

{ #category : #initialization }
SLVMStringConstantValue >> initialize [
	super initialize.
	hasExtraNullCharacter := false.
]

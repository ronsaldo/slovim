"
I represent a string constant.
"
Class {
	#name : #SLVMStringConstantValue,
	#superclass : #SLVMConstantArrayBlob,
	#instVars : [
		'hasExtraNullCharacter'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #converting }
SLVMStringConstantValue >> asBlob [
	^ ByteArray streamContents: [ :out |
		data do: [ :char | out nextPut: char asInteger ].
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

Class {
	#name : #SpirVConstantGenerator,
	#superclass : #Object,
	#category : #'Slovim-SpirV'
}

{ #category : #'as yet unclassified' }
SpirVConstantGenerator >> generateEnum: enum [
	| name values generatedData type isBitValue value |
	name := enum at: 'Name'.
	type := enum at: 'Type'.
	values := enum at: 'Values'.
	isBitValue := type = 'Bit'.
	
	generatedData := String streamContents: [ :out |
		out nextPutAll: 'dataFor' , name; cr.
		out tab; nextPutAll: '^ #('; cr.
		isBitValue ifTrue: [ out tab; tab; nextPutAll: 'None'; space; print: 0; cr].
		
		values keysAndValuesDo: [ :key :rawValue |
			value := isBitValue ifTrue: [ 1 bitShift: rawValue ] ifFalse: [ rawValue ].
			out tab; tab; nextPutAll: key; space; print: value; cr
		].
		out tab; nextPut: $).
	].

	SpirVConstants class compile: generatedData classified: 'constant data'
]

{ #category : #'as yet unclassified' }
SpirVConstantGenerator >> generateEnums: enums [
	| enumNames enumNamesCode |
	enums do: [ :enum | self generateEnum: enum ].
	enumNames := enums collect: [ :enum | enum at: 'Name' ].
	
	enumNamesCode := String streamContents: [ :out |
		out nextPutAll: 'enumNames'; cr.
		out tab; nextPutAll: '^ #('; cr.
		enumNames do: [ :enum |
			out tab; tab; nextPutAll: enum; cr.
		].
		out tab; nextPutAll: ')'; cr.
	].

	SpirVConstants class compile: enumNamesCode classified: 'constant data'
]

{ #category : #'as yet unclassified' }
SpirVConstantGenerator >> generateFrom: constantData [
	| spv |
	spv := constantData at: 'spv'.
	self generateEnums: (spv at: 'enum').
]

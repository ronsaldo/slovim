Class {
	#name : #SLVMLirModule,
	#superclass : #Object,
	#instVars : [
		'compilationTarget',
		'elements'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #adding }
SLVMLirModule >> addElement: anElement [
	elements add: anElement
]

{ #category : #converting }
SLVMLirModule >> asInstructionStream [
	| result |
	result := SLVMLirInstructionStream new compilationTarget: compilationTarget.
	result
		getOrCreateSectionNamed: #'.text';
		getOrCreateSectionNamed: #'.rodata';
		getOrCreateSectionNamed: #'.data';
		getOrCreateSectionNamed: #'.bss'.
	self writeToInstructionStream: result.
	^ result
]

{ #category : #accessing }
SLVMLirModule >> compilationTarget [
	^ compilationTarget
]

{ #category : #accessing }
SLVMLirModule >> compilationTarget: anObject [
	compilationTarget := anObject
]

{ #category : #accessing }
SLVMLirModule >> elements [
	^ elements
]

{ #category : #accessing }
SLVMLirModule >> elements: anObject [
	elements := anObject
]

{ #category : #initialization }
SLVMLirModule >> initialize [
	super initialize.
	elements := OrderedCollection new.
]

{ #category : #printing }
SLVMLirModule >> printOn: aStream [
	elements do: [ :element | element fullPrintOn: aStream. aStream cr ]
]

{ #category : #'as yet unclassified' }
SLVMLirModule >> writeToInstructionStream: instructionStream [
	| elementToLabelMap label |
	elementToLabelMap := Dictionary new.
	elements do: [ :element |
		element isExternal ifTrue: [ 
			label := SLVMLirExternalLabel new name: element name; visibility: element visibility.
		] ifFalse: [ 
			label := SLVMLirLabel new name: element name; visibility: element visibility.
			label type: element labelType.
		].
	
		elementToLabelMap at: element put: label
	].

	elements do: [ :element |
		label := elementToLabelMap at: element.
		label isExternalLabel ifFalse: [ 
			instructionStream withSectionNamed: element section do: [
				instructionStream add: label.
				element writeToInstructionStream: instructionStream moduleElementDictionary: elementToLabelMap.
				instructionStream add: (SLVMLirLabelContentEnd new label: label)
			]
		]
	].

]

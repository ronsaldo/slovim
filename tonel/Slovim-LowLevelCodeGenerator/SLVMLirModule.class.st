Class {
	#name : #SLVMLirModule,
	#superclass : #Object,
	#instVars : [
		'compilationTarget',
		'elements',
		'objectSectionData'
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
		getOrCreateSectionNamed: #'.literal';
		getOrCreateSectionNamed: #'.oop';
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

{ #category : #accessing }
SLVMLirModule >> objectSectionData [
	^ objectSectionData
]

{ #category : #accessing }
SLVMLirModule >> objectSectionData: anObject [
	objectSectionData := anObject
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

	objectSectionData ifNotNil: [
		label := SLVMLirLabel new name: #'_SOopSection'.
		elementToLabelMap at: objectSectionData put: label.
		instructionStream withSectionNamed: #'.oop' do: [
			instructionStream
				add: label;
				add: (SLVMLirBlob new content: objectSectionData contents)
		]
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

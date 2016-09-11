Class {
	#name : #SLVMLirExternalLabel,
	#superclass : #SLVMLirInstructionStreamElement,
	#instVars : [
		'name',
		'visibility',
		'alignment',
		'type'
	],
	#classVars : [
		'VisibilityPrintingPrefix'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Lir'
}

{ #category : #'class initialization' }
SLVMLirExternalLabel class >> initialize [
	super initialize.
	
	"
	Label visibility printing prefixes
	"
	VisibilityPrintingPrefix := IdentityDictionary newFromPairs: #(
		private '.L'
		public ''
	)
]

{ #category : #accessing }
SLVMLirExternalLabel >> alignment [
	^ alignment
]

{ #category : #accessing }
SLVMLirExternalLabel >> alignment: anObject [
	alignment := anObject
]

{ #category : #accessing }
SLVMLirExternalLabel >> asElfSymbol [
	^ self printString
]

{ #category : #'as yet unclassified' }
SLVMLirExternalLabel >> asX86Ptr [
	^ self asX86PtrOfSize: 4
]

{ #category : #'as yet unclassified' }
SLVMLirExternalLabel >> asX86PtrOfSize: accessSize [
	^ SLVMLirX86RegisterAddress new size: accessSize; displacement: self
]

{ #category : #'as yet unclassified' }
SLVMLirExternalLabel >> initialize [
	super initialize.
	alignment := 1.
]

{ #category : #visibility }
SLVMLirExternalLabel >> internal [
	visibility := #internal
]

{ #category : #testing }
SLVMLirExternalLabel >> isExternalLabel [
	^ true
]

{ #category : #'as yet unclassified' }
SLVMLirExternalLabel >> isFunction [
	^ type == #function
]

{ #category : #testing }
SLVMLirExternalLabel >> isImmediate [
	^ true
]

{ #category : #testing }
SLVMLirExternalLabel >> isLabel [
	^ true
]

{ #category : #testing }
SLVMLirExternalLabel >> isSmallImmediate [
	^ false
]

{ #category : #accessing }
SLVMLirExternalLabel >> name [
	^ name
]

{ #category : #accessing }
SLVMLirExternalLabel >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMLirExternalLabel >> printOn: aStream [
	aStream nextPutAll: (VisibilityPrintingPrefix at: visibility); nextPutAll: (name ifNil: [#unnamedLabel]); nextPut: $:
]

{ #category : #visibility }
SLVMLirExternalLabel >> private [
	visibility := #private
]

{ #category : #visibility }
SLVMLirExternalLabel >> public [
	visibility := #public
]

{ #category : #accessing }
SLVMLirExternalLabel >> type [
	^ type
]

{ #category : #accessing }
SLVMLirExternalLabel >> type: anObject [
	type := anObject
]

{ #category : #testing }
SLVMLirExternalLabel >> value [
	^ 0
]

{ #category : #accessing }
SLVMLirExternalLabel >> visibility [
	^ visibility
]

{ #category : #accessing }
SLVMLirExternalLabel >> visibility: anObject [
	visibility := anObject
]

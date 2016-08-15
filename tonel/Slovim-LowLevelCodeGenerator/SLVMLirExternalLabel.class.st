Class {
	#name : #SLVMLirExternalLabel,
	#superclass : #SLVMLirInstructionStreamElement,
	#instVars : [
		'name',
		'visibility'
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
SLVMLirExternalLabel >> asElfSymbol [
	^ self printString
]

{ #category : #visibility }
SLVMLirExternalLabel >> internal [
	visibility := #internal
]

{ #category : #testing }
SLVMLirExternalLabel >> isExternalLabel [
	^ true
]

{ #category : #testing }
SLVMLirExternalLabel >> isImmediate [
	^ true
]

{ #category : #testing }
SLVMLirExternalLabel >> isSmallImmediate [
	^ false
]

{ #category : #printing }
SLVMLirExternalLabel >> printOn: aStream [
	aStream nextPutAll: (VisibilityPrintingPrefix at: visibility); nextPutAll: name; nextPut: $:
]

{ #category : #visibility }
SLVMLirExternalLabel >> private [
	visibility := #private
]

{ #category : #visibility }
SLVMLirExternalLabel >> public [
	visibility := #public
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

Class {
	#name : #SLVMModule,
	#superclass : #SLVMObject,
	#instVars : [
		'globalValues'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #adding }
SLVMModule >> add: aGlobalValue [
	globalValues at: aGlobalValue name put: aGlobalValue
]

{ #category : #adding }
SLVMModule >> globalNamed: aSymbol [
	^ globalValues at: aSymbol
]

{ #category : #accessing }
SLVMModule >> globalValues [
	^ globalValues
]

{ #category : #initialization }
SLVMModule >> initialize [
	globalValues := OrderedDictionary new
]

{ #category : #printing }
SLVMModule >> printOn: aStream [
	globalValues values do: [ :val | val fullPrintOn: aStream ].

]

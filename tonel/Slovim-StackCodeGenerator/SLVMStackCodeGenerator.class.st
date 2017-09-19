Class {
	#name : #SLVMStackCodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'target',
		'translatedElements'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #'as yet unclassified' }
SLVMStackCodeGenerator >> isInliningMandatory [
	^ false
]

{ #category : #accessing }
SLVMStackCodeGenerator >> target [
	^ target
]

{ #category : #accessing }
SLVMStackCodeGenerator >> target: anObject [
	target := anObject
]

{ #category : #'code generation' }
SLVMStackCodeGenerator >> translateModule: module exportList: exportList [
	self applyPassesIn: module functionList: (exportList select: #isFunction).
	translatedElements := Dictionary new.
	
	exportList do: [ :element |
		self translateModuleElement: element
	].
]

{ #category : #'code generation' }
SLVMStackCodeGenerator >> translateModuleElement: element [
	^ element accept: self
]

{ #category : #visiting }
SLVMStackCodeGenerator >> visitFunction: aFunction [
	translatedElements at: aFunction ifPresent: [ :incomplete | ^ incomplete ].

	self halt
]

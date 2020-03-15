"
I am a casting instruction for boxing and unboxing pointers in dynamic objects.
"
Class {
	#name : #SLVMDynamicObjectCompositeCast,
	#superclass : #SLVMCast,
	#instVars : [
		'unchecked'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #testing }
SLVMDynamicObjectCompositeCast class >> isAbstract [
	^ self == SLVMDynamicObjectCompositeCast
]

{ #category : #'as yet unclassified' }
SLVMDynamicObjectCompositeCast class >> source: source targetType: targetType typeObject: typeObject [
	^ self new source: source targetType: targetType typeObject: typeObject
]

{ #category : #initialization }
SLVMDynamicObjectCompositeCast >> initialize [
	super initialize.
	unchecked := false.
]

{ #category : #testing }
SLVMDynamicObjectCompositeCast >> isDynamicObjectReferenceCreator [
	^ true
]

{ #category : #accessing }
SLVMDynamicObjectCompositeCast >> signature [
	^ super signature , { unchecked }
]

{ #category : #'as yet unclassified' }
SLVMDynamicObjectCompositeCast >> source: source targetType: targetType [
	self shouldNotImplement
]

{ #category : #'as yet unclassified' }
SLVMDynamicObjectCompositeCast >> source: source targetType: targetType typeObject: typeObject [
	self parameters: { source . typeObject }.
	type := targetType
	
]

{ #category : #'as yet unclassified' }
SLVMDynamicObjectCompositeCast >> typeObject [
	^ parameters second
]

{ #category : #accessing }
SLVMDynamicObjectCompositeCast >> unchecked [
	^ unchecked
]

{ #category : #accessing }
SLVMDynamicObjectCompositeCast >> unchecked: anObject [
	unchecked := anObject
]

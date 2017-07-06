Class {
	#name : #SLVMGlobalValue,
	#superclass : #SLVMConstant,
	#instVars : [
		'name',
		'properties',
		'visibility',
		'module'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #accessing }
SLVMGlobalValue >> debugInformation [
	^ self propertyAt: #debugInformation ifAbsent: [ nil ]
]

{ #category : #accessing }
SLVMGlobalValue >> debugInformation: aValue [
	^ self propertyAt: #debugInformation put: aValue
]

{ #category : #accessing }
SLVMGlobalValue >> debugSourceLocation [
	^ self propertyAt: #debugSourceLocation ifAbsent: [ nil ]
]

{ #category : #accessing }
SLVMGlobalValue >> debugSourceLocation: aValue [
	^ self propertyAt: #debugSourceLocation put: aValue
]

{ #category : #properties }
SLVMGlobalValue >> hasProperty: aSymbol [
	^ properties includesKey: aSymbol
]

{ #category : #initialization }
SLVMGlobalValue >> initialize [
	super initialize.
	properties := IdentityDictionary new.
	visibility := #public.
]

{ #category : #visibility }
SLVMGlobalValue >> isExternal [
	^ visibility == #external
]

{ #category : #testing }
SLVMGlobalValue >> isFunction [
	^ false
]

{ #category : #testing }
SLVMGlobalValue >> isGlobalValue [
	^ true
]

{ #category : #testing }
SLVMGlobalValue >> isGlobalVariable [
	^ false
]

{ #category : #visibility }
SLVMGlobalValue >> isInternal [
	^ visibility == #internal
]

{ #category : #visibility }
SLVMGlobalValue >> isPrivate [
	^ visibility == #private
]

{ #category : #visibility }
SLVMGlobalValue >> isPublic [
	^ visibility == #public
]

{ #category : #visibility }
SLVMGlobalValue >> isWeak [
	^ visibility == #weak
]

{ #category : #visibility }
SLVMGlobalValue >> makeExternal [
	visibility := #external
]

{ #category : #visibility }
SLVMGlobalValue >> makeInternal [
	visibility := #internal
]

{ #category : #visibility }
SLVMGlobalValue >> makePrivate [
	visibility := #private
]

{ #category : #visibility }
SLVMGlobalValue >> makePublic [
	visibility := #public
]

{ #category : #visibility }
SLVMGlobalValue >> makeWeak [
	visibility := #weak
]

{ #category : #accessing }
SLVMGlobalValue >> module [
	^ module
]

{ #category : #accessing }
SLVMGlobalValue >> module: anObject [
	module := anObject
]

{ #category : #accessing }
SLVMGlobalValue >> name [
	^ name
]

{ #category : #accessing }
SLVMGlobalValue >> name: anObject [
	name := anObject
]

{ #category : #printing }
SLVMGlobalValue >> printOn: aStream [
	aStream nextPut: $@; print: (name ifNil: [#anonymous]).
]

{ #category : #printing }
SLVMGlobalValue >> printPropertiesOn: aStream [
	properties ifEmpty: [ ^ self ].
	aStream nextPut: ${.
	properties associations doWithIndex: [ :assoc :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: assoc.
	].
	aStream nextPut: $}.
]

{ #category : #properties }
SLVMGlobalValue >> properties [
	^ properties
]

{ #category : #properties }
SLVMGlobalValue >> propertyAt: aSymbol [ 
	^ properties at: aSymbol
]

{ #category : #properties }
SLVMGlobalValue >> propertyAt: aSymbol ifAbsent: aBlock [
	^ properties at: aSymbol ifAbsent: aBlock
]

{ #category : #properties }
SLVMGlobalValue >> propertyAt: aSymbol ifAbsentPut: aBlock [
	^ properties at: aSymbol ifAbsentPut: aBlock
]

{ #category : #properties }
SLVMGlobalValue >> propertyAt: aSymbol ifPresent: aBlock [
	^ properties at: aSymbol ifPresent: aBlock
]

{ #category : #properties }
SLVMGlobalValue >> propertyAt: aSymbol put: anObject [
	^ properties at: aSymbol put: anObject
]

{ #category : #accessing }
SLVMGlobalValue >> unmangledName [
	^ self propertyAt: #unmangledName ifAbsent: [ nil ]
]

{ #category : #accessing }
SLVMGlobalValue >> unmangledName: aSymbol [
	self propertyAt: #unmangledName put: aSymbol
]

{ #category : #accessing }
SLVMGlobalValue >> visibility [
	^ visibility
]

{ #category : #accessing }
SLVMGlobalValue >> visibility: newVisibility [
	visibility := newVisibility
]

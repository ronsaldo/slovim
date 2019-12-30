Class {
	#name : #SLVMDebugBasicType,
	#superclass : #SLVMDebugType,
	#category : #'Slovim-Core-Debug'
}

{ #category : #visiting }
SLVMDebugBasicType >> accept: visitor [
	^ visitor visitDebugBasicType: self
]

{ #category : #'as yet unclassified' }
SLVMDebugBasicType >> makeBoolean [
	kind := #boolean.
]

{ #category : #'as yet unclassified' }
SLVMDebugBasicType >> makeCharacter [
	kind := #character.
]

{ #category : #'as yet unclassified' }
SLVMDebugBasicType >> makeFloat [
	kind := #float.
]

{ #category : #'as yet unclassified' }
SLVMDebugBasicType >> makeSignedInteger [
	kind := #signed.
]

{ #category : #'as yet unclassified' }
SLVMDebugBasicType >> makeUnsignedInteger [
	kind := #unsigned.
]

{ #category : #'as yet unclassified' }
SLVMDebugBasicType >> makeVoid [
	kind := #void.
]

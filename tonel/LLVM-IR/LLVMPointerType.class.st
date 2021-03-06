Class {
	#name : #LLVMPointerType,
	#superclass : #LLVMType,
	#instVars : [
		'elementType',
		'addressSpace'
	],
	#category : #'LLVM-IR-Types'
}

{ #category : #'as yet unclassified' }
LLVMPointerType class >> get: elementType addressSpace: addressSpace [
	^ elementType context typeAt: { self . elementType . elementType }
		ifAbsentPut: [
			self new context: elementType context; elementType: elementType; addressSpace: addressSpace
		]
]

{ #category : #'as yet unclassified' }
LLVMPointerType class >> getUnqual: elementType [
	^ self get: elementType addressSpace: 0
]

{ #category : #accessing }
LLVMPointerType >> addressSpace [
	^ addressSpace
]

{ #category : #accessing }
LLVMPointerType >> addressSpace: anObject [
	addressSpace := anObject
]

{ #category : #accessing }
LLVMPointerType >> buildHandle [
	| validElementType |
	validElementType := elementType.
	validElementType isVoidTy ifTrue: [ validElementType := self context int8Ty ].

	handle := validElementType validHandle pointerForAddressSpace: addressSpace
]

{ #category : #'as yet unclassified' }
LLVMPointerType >> computeMemberTypeFor: index [
	^ elementType
]

{ #category : #accessing }
LLVMPointerType >> createName [
	| validElementType |
	validElementType := elementType.
	validElementType isVoidTy ifTrue: [ validElementType := self context int8Ty ].
	
	addressSpace ~= 0 ifTrue: [ ^ '{1} addrspace ({2})*' format: { validElementType name . addressSpace asString } ].
	^ validElementType printString , '*'
]

{ #category : #accessing }
LLVMPointerType >> elementType [
	^ elementType
]

{ #category : #accessing }
LLVMPointerType >> elementType: anObject [
	elementType := anObject
]

{ #category : #initialization }
LLVMPointerType >> initialize [
	super initialize.
	addressSpace := nil
]

{ #category : #testing }
LLVMPointerType >> isPointerTy [
	^ true
]

{ #category : #accessing }
LLVMPointerType >> name [
	^ name ifNil: [ name := self createName ]
]

{ #category : #'as yet unclassified' }
LLVMPointerType >> validateNonRecursiveChildrenWith: visitedSet [
	elementType isStructTy ifTrue: [ 
		elementType hasAlreadyGeneratedName ifTrue: [ ^ self ].
	].
	elementType validateNonRecursionWith: visitedSet.

]

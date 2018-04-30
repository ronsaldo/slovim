Class {
	#name : #LLVMType,
	#superclass : #LLVMObject,
	#instVars : [
		'context',
		'name'
	],
	#category : #'LLVM-IR-Types'
}

{ #category : #'as yet unclassified' }
LLVMType class >> getDoubleTy: context [
	^ context doubleTy
]

{ #category : #'as yet unclassified' }
LLVMType class >> getFloatTy: context [
	^ context floatTy
]

{ #category : #'as yet unclassified' }
LLVMType class >> getInt128Ty: context [
	^ context int128Ty
]

{ #category : #'as yet unclassified' }
LLVMType class >> getInt16Ty: context [
	^ context int16Ty
]

{ #category : #'as yet unclassified' }
LLVMType class >> getInt1Ty: context [
	^ context int1Ty
]

{ #category : #'as yet unclassified' }
LLVMType class >> getInt32Ty: context [
	^ context int32Ty
]

{ #category : #'as yet unclassified' }
LLVMType class >> getInt64Ty: context [
	^ context int64Ty
]

{ #category : #'as yet unclassified' }
LLVMType class >> getInt8Ty: context [
	^ context int8Ty
]

{ #category : #'as yet unclassified' }
LLVMType class >> getLabelTy: context [
	^ context labelTy
]

{ #category : #'as yet unclassified' }
LLVMType class >> getVoidTy: context [
	^ context voidTy
]

{ #category : #accessing }
LLVMType >> context [
	^ context
]

{ #category : #accessing }
LLVMType >> context: anObject [
	context := anObject
]

{ #category : #composition }
LLVMType >> getPointerTo: addressSpace [
	^ LLVMPointerType get: self addressSpace: addressSpace
]

{ #category : #testing }
LLVMType >> isAggregateTy [
	^ false
]

{ #category : #testing }
LLVMType >> isArrayTy [
	^ false
]

{ #category : #testing }
LLVMType >> isDoubleTy [
	^ false
]

{ #category : #testing }
LLVMType >> isEmptyTy [
	^ false
]

{ #category : #testing }
LLVMType >> isFirstClassTy [
	^ false
]

{ #category : #testing }
LLVMType >> isFloatTy [
	^ false
]

{ #category : #testing }
LLVMType >> isFloatingPointTy [
	^ false
]

{ #category : #testing }
LLVMType >> isFunctionTy [
	^ false
]

{ #category : #testing }
LLVMType >> isHalfTy [
	^ false
]

{ #category : #testing }
LLVMType >> isIntOrVectorTy [
	^ false
]

{ #category : #testing }
LLVMType >> isIntegerTy [
	^ false
]

{ #category : #testing }
LLVMType >> isLabelTy [
	^ false
]

{ #category : #testing }
LLVMType >> isMetadataTy [
	^ false
]

{ #category : #testing }
LLVMType >> isPointerTy [
	^ false
]

{ #category : #testing }
LLVMType >> isPtrOrPtrVectorTy [
	^ false
]

{ #category : #testing }
LLVMType >> isSingleValueTy [
	^ false
]

{ #category : #testing }
LLVMType >> isStructTy [
	^ false
]

{ #category : #testing }
LLVMType >> isTokenTy [
	^ false
]

{ #category : #testing }
LLVMType >> isVectorTy [
	^ false
]

{ #category : #testing }
LLVMType >> isVoidTy [
	^ false
]

{ #category : #accessing }
LLVMType >> name [
	^ name
]

{ #category : #accessing }
LLVMType >> name: anObject [
	name := anObject
]

{ #category : #composition }
LLVMType >> printOn: aStream [
	aStream nextPutAll: self name
]
Class {
	#name : #SLVMReferenceType,
	#superclass : #SLVMType,
	#instVars : [
		'baseType',
		'storage'
	],
	#category : #'Slovim-Core-Type'
}

{ #category : #construction }
SLVMReferenceType class >> baseType: aBaseType storage: storage [
	^ self new baseType: aBaseType; storage: storage; yourself
]

{ #category : #'class initialization' }
SLVMReferenceType class >> initialize [
	"
	self initialize
	"
	super initialize.

	UniformConstantStorage := #uniform.
	UniformStorage := 	#uniform.
	InputStorage := #input.
	OutputStorage := #output.
	GenericStorage := #generic.
	WorkgroupStorage := #workgroup.
	CrossWorkgroupStorage := #crossWorkgroup.
	PrivateStorage := #private.
	FunctionStorage := #function.
	GenericStorage := #generic.
	
]

{ #category : #comparing }
SLVMReferenceType >> = other [
	^ self class == other class and: [ baseType = other baseType and: [ storage = other storage ] ] 
]

{ #category : #visitor }
SLVMReferenceType >> accept: aVisitor [
	^ aVisitor visitReferenceType: self
]

{ #category : #accessing }
SLVMReferenceType >> alignmentForTarget: compilationTarget [
	^ compilationTarget referenceAlignment
]

{ #category : #accessing }
SLVMReferenceType >> baseType [
	^ baseType
]

{ #category : #accessing }
SLVMReferenceType >> baseType: aType [
	self assert: aType isSlovimType.
	baseType := aType
]

{ #category : #comparing }
SLVMReferenceType >> hash [
	^ (self class hash bitXor: baseType hash) bitXor: storage hash
]

{ #category : #testing }
SLVMReferenceType >> isReferenceType [
	^ true
]

{ #category : #testing }
SLVMReferenceType >> isScalarType [
	^ true
]

{ #category : #printing }
SLVMReferenceType >> printOn: aStream [
	aStream print: baseType;
		nextPutAll: ' ref '; print: storage
]

{ #category : #accessing }
SLVMReferenceType >> referenceTypeOfMemberAt: index [
	^ SLVMReferenceType baseType: (self typeOfMemberAt: index) storage: storage
]

{ #category : #accessing }
SLVMReferenceType >> sizeForTarget: compilationTarget [
	^ compilationTarget referenceSize
]

{ #category : #accessing }
SLVMReferenceType >> storage [
	^ storage
]

{ #category : #accessing }
SLVMReferenceType >> storage: aSymbol [
	self assert: aSymbol isSymbol.
	storage := aSymbol
]

{ #category : #accessing }
SLVMReferenceType >> typeOfMemberAt: index [
	^ baseType memberAt: index
]

Class {
	#name : #SLVMConstantCompiledMethodMetaData,
	#superclass : #SLVMConstant,
	#instVars : [
		'type',
		'sourceMethod'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #comparing }
SLVMConstantCompiledMethodMetaData >> = other [
	^ self class = other class and: [ sourceMethod == other sourceMethod ]
]

{ #category : #comparing }
SLVMConstantCompiledMethodMetaData >> hash [
	^ self class hash bitXor: sourceMethod identityHash
]

{ #category : #testing }
SLVMConstantCompiledMethodMetaData >> isCompiledMethodMetaData [
	^ true
]

{ #category : #accessing }
SLVMConstantCompiledMethodMetaData >> sourceMethod [
	^ sourceMethod
]

{ #category : #accessing }
SLVMConstantCompiledMethodMetaData >> sourceMethod: anObject [
	sourceMethod := anObject
]

{ #category : #accessing }
SLVMConstantCompiledMethodMetaData >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantCompiledMethodMetaData >> type: anObject [
	type := anObject
]

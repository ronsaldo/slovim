Class {
	#name : #LLVMGlobalVariable,
	#superclass : #LLVMGlobalObject,
	#instVars : [
		'valueType',
		'isConstant',
		'initialValue'
	],
	#category : #'LLVM-IR-GlobalValues'
}

{ #category : #'as yet unclassified' }
LLVMGlobalVariable class >> createWithType: valueType module: module isConstant: isConstant linkage: linkage [
	^ self createWithType: valueType module: module isConstant: isConstant linkage: linkage name: nil threadLocalMode: NotThreadLocal addressSpace: 0
]

{ #category : #'as yet unclassified' }
LLVMGlobalVariable class >> createWithType: valueType module: module isConstant: isConstant linkage: linkage name: aName [
	^ self createWithType: valueType module: module isConstant: isConstant linkage: linkage  name: aName threadLocalMode: NotThreadLocal addressSpace: 0
]

{ #category : #'as yet unclassified' }
LLVMGlobalVariable class >> createWithType: valueType module: module isConstant: isConstant linkage: linkage name: aName threadLocalMode: threadLocalMode addressSpace: addressSpace [
	^ self new initializeWithType: valueType module: module isConstant: isConstant linkage: linkage  name: aName threadLocalMode: threadLocalMode addressSpace: addressSpace
]

{ #category : #printing }
LLVMGlobalVariable >> fullPrintOn: aStream [
	aStream print: self; nextPutAll: ' = '.
	aStream << linkage second << ' ' << visibility second.
	type addressSpace ~= 0 ifTrue: [ 
		aStream << 'addrspace(' << type addressSpace << ')'
	].

	aStream space; nextPutAll: (isConstant ifTrue: [ 'constant' ] ifFalse: [ 'global' ]);
		space; print: valueType.
	initialValue ifNotNil: [ aStream space; print: initialValue ]
	
]

{ #category : #accessing }
LLVMGlobalVariable >> initialValue [
	^ initialValue
]

{ #category : #accessing }
LLVMGlobalVariable >> initialValue: anObject [
	initialValue := anObject
]

{ #category : #initialization }
LLVMGlobalVariable >> initializeWithType: theValueType module: theModule isConstant: isConstantValue linkage: theLinkage name: aName threadLocalMode: theThreadLocalMode addressSpace: theAddressSpace [
	valueType := theValueType.
	isConstant := isConstantValue.
	self type: (LLVMPointerType get: valueType addressSpace: theAddressSpace).
	self name: aName.
	self threadLocalMode: theThreadLocalMode.
	self linkage: theLinkage.
	theModule ifNotNil: [
		theModule addGlobalValue: self
	].
	
	

]

{ #category : #accessing }
LLVMGlobalVariable >> isConstant [
	^ isConstant
]

{ #category : #accessing }
LLVMGlobalVariable >> valueType [
	^ valueType
]

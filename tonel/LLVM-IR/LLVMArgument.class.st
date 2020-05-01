Class {
	#name : #LLVMArgument,
	#superclass : #LLVMValue,
	#instVars : [
		'parent',
		'argNo',
		'flags'
	],
	#category : #'LLVM-IR'
}

{ #category : #adding }
LLVMArgument >> addFlag: flag [
	flags := flags copyWith: flag
]

{ #category : #accessing }
LLVMArgument >> argNo [
	^ argNo
]

{ #category : #accessing }
LLVMArgument >> argNo: anObject [
	argNo := anObject
]

{ #category : #accessing }
LLVMArgument >> flags [
	^ flags
]

{ #category : #accessing }
LLVMArgument >> flags: anObject [
	flags := anObject
]

{ #category : #initialization }
LLVMArgument >> initialize [
	super initialize.
	flags := #().
]

{ #category : #accessing }
LLVMArgument >> parent [
	^ parent
]

{ #category : #accessing }
LLVMArgument >> parent: anObject [
	parent := anObject
]

{ #category : #printing }
LLVMArgument >> printOnDeclaration: aStream [
	aStream print: type.
	flags do: [ :flag | aStream space; nextPutAll: flag ].
]

{ #category : #printing }
LLVMArgument >> printOnDefinition: aStream [
	aStream print: type.
	flags do: [ :flag | aStream space; nextPutAll: flag ].
	
	name isLLVMAnon ifFalse: [ 
		aStream nextPutAll: ' %'; nextPutAll: name.
	].

]

"
I represent a value that is captured by a closure.

basicInitialValue: value that must be set before calling the copy function for initialization.
copyFunction: a function that must be used for setting the capture initial value.
moveFunction: a function that must be used for moving a capture value from one place into another.
"
Class {
	#name : #SLVMClosureCapture,
	#superclass : #SLVMFunctionLocalValue,
	#instVars : [
		'type',
		'index',
		'basicInitialValue',
		'copyFunction',
		'moveFunction',
		'finalizeFunction',
		'properties'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMClosureCapture class >> mnemonics [
	^ #()
]

{ #category : #printing }
SLVMClosureCapture >> asFullSExpression [
	^ { name . type asSExpression . self flags sorted }
]

{ #category : #accessing }
SLVMClosureCapture >> basicInitialValue [
	^ basicInitialValue
]

{ #category : #accessing }
SLVMClosureCapture >> basicInitialValue: anObject [
	basicInitialValue := anObject
]

{ #category : #accessing }
SLVMClosureCapture >> copyFunction [
	^ copyFunction
]

{ #category : #accessing }
SLVMClosureCapture >> copyFunction: anObject [
	copyFunction := anObject
]

{ #category : #accessing }
SLVMClosureCapture >> finalizeFunction [
	^ finalizeFunction
]

{ #category : #accessing }
SLVMClosureCapture >> finalizeFunction: anObject [
	finalizeFunction := anObject
]

{ #category : #accessing }
SLVMClosureCapture >> index [
	^ index
]

{ #category : #accessing }
SLVMClosureCapture >> index: anObject [
	index := anObject
]

{ #category : #testing }
SLVMClosureCapture >> isClosureCapture [
	^ true
]

{ #category : #accessing }
SLVMClosureCapture >> moveFunction [
	^ moveFunction
]

{ #category : #accessing }
SLVMClosureCapture >> moveFunction: anObject [
	moveFunction := anObject
]

{ #category : #accessing }
SLVMClosureCapture >> properties [
	^ properties ifNil: [ properties := Dictionary new ]
]

{ #category : #accessing }
SLVMClosureCapture >> propertyAt: aSymbol [ 
	^ self properties at: aSymbol
]

{ #category : #accessing }
SLVMClosureCapture >> propertyAt: aSymbol put: anObject [
	^ self properties at: aSymbol put: anObject
]

{ #category : #'as yet unclassified' }
SLVMClosureCapture >> requiredInitialValueType [
	copyFunction ifNotNil: [ ^ copyFunction arguments second type ].
	^ type
]

{ #category : #accessing }
SLVMClosureCapture >> type [
	^ type
]

{ #category : #accessing }
SLVMClosureCapture >> type: anObject [
	type := anObject
]

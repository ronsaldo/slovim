Class {
	#name : #SLVMNativeRuntimeObjectModel,
	#superclass : #SLVMObjectModel,
	#category : #'Slovim-Core-Type'
}

{ #category : #testing }
SLVMNativeRuntimeObjectModel >> isInlineLiteral: literal [
	| literalClass |
	literalClass := literal class.
	(literalClass includesBehavior: Boolean) ifTrue: [ ^ true].
	(literalClass includesBehavior: Float) ifTrue: [ self halt ].
	(literalClass includesBehavior: Integer) ifTrue: [ self halt ].
	(literalClass includesBehavior: UndefinedObject) ifTrue: [ ^ true].
	^ false
]

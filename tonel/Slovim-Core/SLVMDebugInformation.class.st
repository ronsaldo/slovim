Class {
	#name : #SLVMDebugInformation,
	#superclass : #SLVMObject,
	#instVars : [
		'flags'
	],
	#category : #'Slovim-Core-Debug'
}

{ #category : #visiting }
SLVMDebugInformation >> accept: visitor [
	^ self subclassResponsibility
]

{ #category : #initialization }
SLVMDebugInformation >> addFlag: flag [
	self flags: ((self flags copyWithout: flag) copyWith: flag)

]

{ #category : #accessing }
SLVMDebugInformation >> flags [
	^ flags ifNil: [ flags := #() ]
]

{ #category : #accessing }
SLVMDebugInformation >> flags: someFlags [
	flags := someFlags
]

{ #category : #initialization }
SLVMDebugInformation >> hasFlag: flag [
	^ self flags includes: flag
]

{ #category : #testing }
SLVMDebugInformation >> isDebugDerivedType [
	^ false
]

{ #category : #testing }
SLVMDebugInformation >> isDebugType [
	^ false
]

{ #category : #'as yet unclassified' }
SLVMDebugInformation >> makeArtificial [
	^ self addFlag: #artificial
]

{ #category : #'as yet unclassified' }
SLVMDebugInformation >> makeNoReturn [
	^ self addFlag: #noReturn
]

{ #category : #'as yet unclassified' }
SLVMDebugInformation >> makeNonTrivial [
	^ self addFlag: #nonTrivial
]

{ #category : #'as yet unclassified' }
SLVMDebugInformation >> makeSingleInheritance [
	^ self addFlag: #singleInheritance
]

{ #category : #'as yet unclassified' }
SLVMDebugInformation >> makeThunk [
	^ self addFlag: #thunk
]

{ #category : #initialization }
SLVMDebugInformation >> removeFlag: flag [
	self flags: (self flags copyWithout: flag)
]

{ #category : #accessing }
SLVMDebugInformation >> scope [
	^ nil
]

{ #category : #initialization }
SLVMDebugInformation >> setFlag: flag value: aBoolean [
	aBoolean ifTrue: [
		self addFlag: flag
	] ifFalse: [ 
		self removeFlag: flag
	]
]

{ #category : #'as yet unclassified' }
SLVMDebugInformation >> slvmEncodeAsSExpression [
	^ nil
]

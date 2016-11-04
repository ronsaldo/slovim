Class {
	#name : #SLVMOpalLocalScope,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'parentScope',
		'selfValue',
		'variables',
		'thisContextEmitter'
	],
	#category : #'Slovim-OpalCompiler-Translator'
}

{ #category : #adding }
SLVMOpalLocalScope >> addBlock: block symbol: symbol [
	variables at: symbol put: block
]

{ #category : #adding }
SLVMOpalLocalScope >> addValue: value symbol: symbol [
	self addBlock: [ value ] symbol: symbol
]

{ #category : #accessing }
SLVMOpalLocalScope >> emitThisContext: builder [
	thisContextEmitter ifNotNil: [ ^ thisContextEmitter value: builder].
	parentScope ifNil: [ self error: 'Cannot emit this context.' ].
	^ parentScope emitThisContext: builder
]

{ #category : #'as yet unclassified' }
SLVMOpalLocalScope >> includesSymbol: aSymbol [
	^ variables includesKey: aSymbol
]

{ #category : #initialization }
SLVMOpalLocalScope >> initialize [
	variables := Dictionary new.
]

{ #category : #'symbol lookup' }
SLVMOpalLocalScope >> lookSymbol: symbol [
	^ variables at: symbol
]

{ #category : #'symbol lookup' }
SLVMOpalLocalScope >> lookSymbolRecursively: symbol [
	variables at: symbol ifPresent: [ :result | ^ result ].
	parentScope ifNil: [ self error: 'failed to look variable.' ].
	^ parentScope lookSymbolRecursively: symbol
]

{ #category : #'symbol lookup' }
SLVMOpalLocalScope >> lookSymbolRecursively: symbol withBuilder: builder [
	^ (self lookSymbolRecursively: symbol) cull: builder cull: self
]

{ #category : #accessing }
SLVMOpalLocalScope >> parentScope [
	^ parentScope
]

{ #category : #accessing }
SLVMOpalLocalScope >> parentScope: anObject [
	parentScope := anObject
]

{ #category : #accessing }
SLVMOpalLocalScope >> selfValue [
	^ selfValue
]

{ #category : #accessing }
SLVMOpalLocalScope >> selfValue: anObject [
	selfValue := anObject
]

{ #category : #accessing }
SLVMOpalLocalScope >> thisContextEmitter [
	^ thisContextEmitter
]

{ #category : #accessing }
SLVMOpalLocalScope >> thisContextEmitter: anObject [
	thisContextEmitter := anObject
]

{ #category : #accessing }
SLVMOpalLocalScope >> variables [
	^ variables
]

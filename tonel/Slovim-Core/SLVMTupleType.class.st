Class {
	#name : #SLVMTupleType,
	#superclass : #SLVMStructureType,
	#category : #'Slovim-Core-Type'
}

{ #category : #accessing }
SLVMTupleType class >> types: aListOfTypes [
	^ self name: nil types: aListOfTypes kind: self genericKind names: nil
]

{ #category : #comparing }
SLVMTupleType >> = other [
	^ self class == other class and: [ types = other types ]
]

{ #category : #visitor }
SLVMTupleType >> accept: aVisitor [
	^ aVisitor visitTupleType: self
]

{ #category : #accessing }
SLVMTupleType >> createTupleTypeName [
	^ ByteString streamContents: [ :out |
		out nextPutAll: '__tuple'.
		types do: [ :type |
			out nextPut: $_; nextPutAll: type name
		]
	]
]

{ #category : #printing }
SLVMTupleType >> fullPrintOn: aStream fromPrint: aBoolean [
	aStream nextPutAll: 'tuple {'.
	types doWithIndex: [ :type :index |
		index > 1 ifTrue: [ aStream nextPutAll: ', ' ].
		aStream print: type
	].
	aStream nextPutAll: '}'.
	aBoolean ifFalse: [ aStream cr ]
	
]

{ #category : #comparing }
SLVMTupleType >> hash [
	^ self class identityHash bitXor: types hash
]

{ #category : #testing }
SLVMTupleType >> isTupleType [
	^ true
	
]

{ #category : #accessing }
SLVMTupleType >> name [
	^ name ifNil: [ name := self createTupleTypeName ]
]

{ #category : #accessing }
SLVMTupleType >> names [
	^ names ifNil: [ names := (0 to: types size - 1) collect: [ :i | ('f' , i asString) asSymbol]]
]

{ #category : #printing }
SLVMTupleType >> printOn: aStream [
	self fullPrintOn: aStream fromPrint: true
]

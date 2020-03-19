Class {
	#name : #SLVMSerializationGraphEncoder,
	#superclass : #Object,
	#instVars : [
		'typeMapTable',
		'mode',
		'encodedObjects'
	],
	#pools : [
		'SLVMSerializationGraphEncodingConstants'
	],
	#category : #'Slovim-Core-Serialization'
}

{ #category : #'as yet unclassified' }
SLVMSerializationGraphEncoder >> encodeObject: object type: type earlyFields: earlyFields fields: fieldsEncodingBlock [
	self assert: type isNotNil.
	typeMapTable ifNotNil: [
		self assert: ((typeMapTable includesKey: type) or: [BasicTypeTableMap includesKey: type])
	].

	^ encodedObjects at: object ifAbsent: [
			| proxy |
			proxy := SLVMSerializationGraphObjectProxy new
				object: object;
				type: type;
				earlyFields: earlyFields value;
				yourself.
			encodedObjects at: object put: proxy.
			proxy
				fields: fieldsEncodingBlock value.
			proxy
		].
]

{ #category : #'as yet unclassified' }
SLVMSerializationGraphEncoder >> encodeObject: object type: type fields: fieldsEncodingBlock [
	^ self encodeObject: object type: type earlyFields: nil fields: fieldsEncodingBlock
]

{ #category : #'as yet unclassified' }
SLVMSerializationGraphEncoder >> encodeSymbolTable: aDictionary valuesWith: aBlock [
	^ aDictionary keys sorted collect: [ :key | {key . aBlock value: (aDictionary at: key) } ]
]

{ #category : #initialization }
SLVMSerializationGraphEncoder >> initialize [
	super initialize.
	encodedObjects := IdentityDictionary new.
]

{ #category : #testing }
SLVMSerializationGraphEncoder >> isExportMode [
	^ mode == #export
]

{ #category : #testing }
SLVMSerializationGraphEncoder >> setExportMode [
	^ mode := #export
]

{ #category : #accessing }
SLVMSerializationGraphEncoder >> typeMapTable [
	^ typeMapTable
]

{ #category : #accessing }
SLVMSerializationGraphEncoder >> typeMapTable: anObject [
	typeMapTable := anObject
]

Class {
	#name : #SLVMSerializationGraphEncodingConstants,
	#superclass : #SharedPool,
	#classVars : [
		'BasicTypeTableMap'
	],
	#category : #'Slovim-Core-Serialization'
}

{ #category : #'class initialization' }
SLVMSerializationGraphEncodingConstants class >> initialize [
	BasicTypeTableMap := Dictionary newFromPairs: {
		#Array . Array.
		#OrderedCollection . OrderedCollection.
		#OrderedDictionary . OrderedDictionary.
		#Dictionary . Dictionary.
		#Set . Set
	}.
]

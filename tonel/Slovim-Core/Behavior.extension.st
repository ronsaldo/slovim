Extension { #name : #Behavior }

{ #category : #'*Slovim-Core' }
Behavior >> makeInstanceForMessagePackGraphMaterializationWith: graphDecoder [
	^ self new
]

{ #category : #'*Slovim-Core' }
Behavior >> materializeObjectWithType: objectType earlyFields: earlyFields withMessagePackGraphDecoder: graphDecoder [
	| objectInstance fields |
	objectInstance := self makeInstanceForMessagePackGraphMaterializationWith: graphDecoder.
	graphDecoder registerObjectInstance: objectInstance.
	
	fields := Dictionary newFromPairs: graphDecoder decodeNext.
	objectInstance materializeWithGraphDecoder: graphDecoder withFields: fields.
	^ objectInstance
]

{ #category : #'*Slovim-Core' }
Behavior >> materializeObjectWithType: objectType withMessagePackGraphDecoder: graphDecoder [
	| objectInstance fields |
	objectInstance := self makeInstanceForMessagePackGraphMaterializationWith: graphDecoder.
	graphDecoder registerObjectInstance: objectInstance.
	
	fields := Dictionary newFromPairs: graphDecoder decodeNext.
	objectInstance materializeWithGraphDecoder: graphDecoder withFields: fields.
	^ objectInstance
]

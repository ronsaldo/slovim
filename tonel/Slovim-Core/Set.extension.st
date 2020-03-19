Extension { #name : #Set }

{ #category : #'*Slovim-Core' }
Set >> encodeGraphForMessagePackWith: graphEncoder [
	^ graphEncoder encodeObject: self type: #Set earlyFields: self size fields: [self collect: [:each | each encodeGraphForMessagePackWith: graphEncoder]]
]

{ #category : #'*Slovim-Core' }
Set class >> materializeObjectWithType: objectType earlyFields: earlyFields withMessagePackGraphDecoder: graphDecoder [
	objectType == #Set ifTrue: [
		| result |
		result := self new: earlyFields.
		graphDecoder registerObjectInstance: result.
		graphDecoder decodeNext do: [ :eachValue |
			result add: eachValue
		].
		^ result
	].

	^ super materializeObjectWithType: objectType earlyFields: earlyFields withMessagePackGraphDecoder: graphDecoder
]

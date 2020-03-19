Extension { #name : #OrderedCollection }

{ #category : #'*Slovim-Core' }
OrderedCollection >> encodeGraphForMessagePackWith: graphEncoder [
	^ graphEncoder encodeObject: self type: #OrderedCollection earlyFields: self size fields: [self collect: [:each | each encodeGraphForMessagePackWith: graphEncoder] as: Array]
]

{ #category : #'*Slovim-Core' }
OrderedCollection class >> materializeObjectWithType: objectType earlyFields: earlyFields withMessagePackGraphDecoder: graphDecoder [
	objectType == #OrderedCollection ifTrue: [
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

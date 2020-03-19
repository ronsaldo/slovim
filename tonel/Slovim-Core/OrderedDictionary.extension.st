Extension { #name : #OrderedDictionary }

{ #category : #'*Slovim-Core' }
OrderedDictionary >> encodeGraphForMessagePackWith: graphEncoder [
	^ graphEncoder encodeObject: self type: #OrderedDictionary earlyFields: self size fields: [
		Array streamContents: [ :out |
			self keysDo: [ :key |
				out nextPut: (key encodeGraphForMessagePackWith: graphEncoder);
					nextPut: ((self at: key) encodeGraphForMessagePackWith: graphEncoder)
			]
		]
	]
]

{ #category : #'*Slovim-Core' }
OrderedDictionary class >> materializeObjectWithType: objectType earlyFields: earlyFields withMessagePackGraphDecoder: graphDecoder [
	objectType == #OrderedDictionary ifTrue: [
		| result |
		result := self new: earlyFields.
		graphDecoder registerObjectInstance: result.
		graphDecoder decodeNext pairsDo: [ :key :value |
			result at: key put: value
		].
		^ result
	].

	^ super materializeObjectWithType: objectType earlyFields: earlyFields withMessagePackGraphDecoder: graphDecoder
]

Extension { #name : #Array }

{ #category : #'*Slovim-Core' }
Array >> encodeGraphForMessagePackWith: graphEncoder [
	^ graphEncoder encodeObject: self type: #Array earlyFields: self size fields: [self collect: [:each | each encodeGraphForMessagePackWith: graphEncoder]]
]

{ #category : #'*Slovim-Core' }
Array class >> materializeObjectWithType: objectType earlyFields: earlyFields withMessagePackGraphDecoder: graphDecoder [
	objectType == #Array ifTrue: [
		| result |
		result := self new: earlyFields.
		graphDecoder registerObjectInstance: result.
		graphDecoder decodeNext doWithIndex: [ :eachValue :index |
			result at: index put: eachValue
		].
		^ result
	].

	^ super materializeObjectWithType: objectType earlyFields: earlyFields withMessagePackGraphDecoder: graphDecoder
]

{ #category : #'*Slovim-Core' }
Array >> slvmEncodeAsSExpression [
	^ { #array . self collect: [ :each | each slvmEncodeAsSExpression ]  }
]

Extension { #name : #Number }

{ #category : #'*Slovim-Core' }
Number >> encodeGraphForMessagePackWith: encoder [
	^ self asFloat
]

{ #category : #'*Slovim-Core' }
Number >> slvmEncodeAsSExpression [
	^ self
]

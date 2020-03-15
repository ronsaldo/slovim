Extension { #name : #IdentityDictionary }

{ #category : #'*Slovim-Core' }
IdentityDictionary >> slvmEncodeAsSExpression [
	^ { #identityDictionary } , (Array streamContents: [:out |
		self keysAndValuesDo: [ :key :value |
			out nextPut: key slvmEncodeAsSExpression; nextPut: value slvmEncodeAsSExpression
		]
	])
]

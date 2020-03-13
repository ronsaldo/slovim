Extension { #name : #Array }

{ #category : #'*Slovim-Core' }
Array >> slvmEncodeAsSExpression [
	^ { #array . self collect: [ :each | each slvmEncodeAsSExpression ]  }
]

Extension { #name : #LiteralVariable }

{ #category : #'*Slovim-Core' }
LiteralVariable >> slvmEncodeAsSExpression [
	^ { #literalVariable . ((self respondsTo: #name) ifTrue: [self name] ifFalse: [self key]) }
]

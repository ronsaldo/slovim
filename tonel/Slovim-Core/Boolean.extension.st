Extension { #name : #Boolean }

{ #category : #'*Slovim-Core' }
Boolean >> encodeGraphForMessagePackWith: encoder [
	^ self
]

{ #category : #'*Slovim-Core' }
Boolean >> isSLVMDynamicInlineLiteral [
	^ true
]

{ #category : #'*Slovim-Core' }
Boolean >> slvmEncodeAsSExpression [
	^ self
]

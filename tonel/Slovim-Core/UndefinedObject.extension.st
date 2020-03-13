Extension { #name : #UndefinedObject }

{ #category : #'*Slovim-Core' }
UndefinedObject >> isSLVMDynamicInlineLiteral [
	^ true
]

{ #category : #'*Slovim-Core' }
UndefinedObject >> slvmEncodeAsSExpression [
	^ self
]

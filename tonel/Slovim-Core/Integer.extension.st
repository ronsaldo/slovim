Extension { #name : #Integer }

{ #category : #'*Slovim-Core' }
Integer >> encodeGraphForMessagePackWith: encoder [
	^ self
]

{ #category : #'*Slovim-Core' }
Integer >> isSLVMDynamicInlineLiteral [
	^ true
]

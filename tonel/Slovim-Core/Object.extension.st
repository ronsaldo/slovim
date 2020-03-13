Extension { #name : #Object }

{ #category : #'*Slovim-Core' }
Object >> isSLVMDynamicInlineLiteral [
	^ false
]

{ #category : #'*Slovim-Core' }
Object >> isSLVMObject [
	^ false
]

{ #category : #'*Slovim-Core' }
Object >> slvmEncodeAsSExpression [
	^ self subclassResponsibility
]

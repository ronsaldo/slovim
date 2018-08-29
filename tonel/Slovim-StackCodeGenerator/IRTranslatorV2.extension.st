Extension { #name : #IRTranslatorV2 }

{ #category : #'*Slovim-StackCodeGenerator' }
IRTranslatorV2 >> visitSLVMTempVector: tempVector [
	tempVectorStack push: tempVector.
	tempVector vars size > 127 ifTrue: [ 
		gen
			pushLiteralVariable: Array binding;
			pushLiteral: tempVector vars size;
			send: #basicNew:;
			storePopTemp: (self currentScope indexForVarNamed: tempVector name).
	] ifFalse: [ 
		gen pushNewArray: tempVector vars size. 
		gen storePopTemp: (self currentScope indexForVarNamed: tempVector name).
	].

]

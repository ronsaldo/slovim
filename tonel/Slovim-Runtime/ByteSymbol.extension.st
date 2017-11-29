Extension { #name : #ByteSymbol }

{ #category : #'*Slovim-Runtime' }
ByteSymbol >> asSLVMType [
	^ SLVMCompilationTargetTypes forCurrentImage perform: self
]

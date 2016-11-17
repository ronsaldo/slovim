Extension { #name : #OCLiteralVariable }

{ #category : #'*Slovim-OpalCompiler' }
OCLiteralVariable >> emitSLVM: builder store: value scope: slvmScope [
	| literalVariable |
	literalVariable := self literalVariableForSlovimBuilder: builder.
	^ builder store: value in: (builder getReference: literalVariable element: (builder constInt: 1))
]

{ #category : #'*Slovim-OpalCompiler' }
OCLiteralVariable >> emitSLVMValue: builder scope: slvmScope [
	| literalVariable |
	literalVariable := self literalVariableForSlovimBuilder: builder.
	^ builder load: (builder getReference: literalVariable element: (builder constInt: 1))
]

{ #category : #'*Slovim-OpalCompiler' }
OCLiteralVariable >> literalVariableForSlovimBuilder: builder [
	self isGlobalVariable ifTrue: [
		^ builder addDynamicLiteral: assoc
	].

	self isClassVariable ifTrue: [
		builder registerClassVariable: assoc class: self definingScope class binding.
		^ builder addDynamicLiteral: assoc
	].

	self error: 'Unsupported literal variable type.'.
]

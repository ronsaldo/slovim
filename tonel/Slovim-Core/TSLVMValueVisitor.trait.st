Trait {
	#name : #TSLVMValueVisitor,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
TSLVMValueVisitor >> visitAlloca: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitBinaryOperation: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitBranch: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitCall: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitCast: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitCombineSamplerWithTexture: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitConstantUndefined: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitExtractVectorElement: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitGetElementPointer: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitGetFramePointer: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitInsertVectorElement: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitJump: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitLoad: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitMakeMatrix: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitMakeVector: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitMessageSend: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitPhi: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitReturn: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitReturnVoid: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitSampleDepthImplicitLod: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitSampleDepthRefImplicitLod: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitSampleExplicitGradient: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitSampleExplicitLod: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitSampleImplicitLod: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitShuffleVectors: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitStore: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitSwitch: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitUnaryOperation: instruction [
	self explicitRequirement
]

{ #category : #visiting }
TSLVMValueVisitor >> visitUnreachable: instruction [
	self explicitRequirement
]

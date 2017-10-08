"
I am a SSA value visitor.
"
Class {
	#name : #SLVMValueVisitor,
	#superclass : #SLVMObject,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMValueVisitor >> visitAlloca: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitBinaryOperation: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitBranch: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitCall: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitCast: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitCombineSamplerWithTexture: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitExtractVectorElement: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitGetElementPointer: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitGetFramePointer: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitJump: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitLoad: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitMakeMatrix: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitMakeVector: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitMessageSend: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitPhi: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitReturn: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitReturnVoid: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitSampleImplicitLod: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitShuffleVectors: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitStore: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitUnaryOperation: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitUndefinedInstruction: instruction [
]

{ #category : #visiting }
SLVMValueVisitor >> visitUnreachable: instruction [
]

Class {
	#name : #SLVMBuilder,
	#superclass : #SLVMObject,
	#instVars : [
		'function',
		'currentBlock'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'instance creation' }
SLVMBuilder class >> on: aFunction [
	^ self new function: aFunction
]

{ #category : #instructions }
SLVMBuilder >> add: left with: right [
	^ self add: left with: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> add: left with: right name: resultName [
	^ self addOperation: #add left: left right: right name: resultName
]

{ #category : #adding }
SLVMBuilder >> addDynamicLiteral: literal [
	literal isSLVMDynamicInlineLiteral ifTrue: [ ^ SLVMConstantValue type: SLVMType dynamicObjectType value: literal ].
	^ function addDynamicLiteral: literal
]

{ #category : #adding }
SLVMBuilder >> addInstruction: anInstruction name: theInstructionName [
	anInstruction name: theInstructionName.
	currentBlock add: anInstruction.
	^ anInstruction
]

{ #category : #adding }
SLVMBuilder >> addOperation: operation left: left right: right [
	^ self addOperation: operation left: left right: right name: function generateSymbol
]

{ #category : #adding }
SLVMBuilder >> addOperation: operation left: left right: right name: name [
	^ self addInstruction: (SLVMBinaryOperation operation: operation left: left right: right) name: name
]

{ #category : #adding }
SLVMBuilder >> addOperation: operation operand: operand [
	^ self addOperation: operation operand: operand name: function generateSymbol
]

{ #category : #adding }
SLVMBuilder >> addOperation: operation operand: operand name: name [
	^ self addInstruction: (SLVMUnaryOperation operation: operation operand: operand) name: name
]

{ #category : #instructions }
SLVMBuilder >> alloca: valueType [
	^ self alloca: valueType name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> alloca: valueType name: variableName [
	^ self addInstruction: (SLVMAlloca valueType: valueType) name: variableName
]

{ #category : #instructions }
SLVMBuilder >> branch: condition ifTrue: ifTrueBlock ifFalse: ifFalseBlock [
	^ self branch: condition ifTrue: ifTrueBlock ifFalse: ifFalseBlock name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> branch: condition ifTrue: ifTrueBlock ifFalse: ifFalseBlock name: resultName [
	^ self addInstruction: (SLVMBranch condition: condition ifTrue: ifTrueBlock ifFalse: ifFalseBlock) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> call: functionValue arguments: arguments [
	^ self call: functionValue arguments: arguments name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> call: functionValue arguments: arguments name: resultName [
	^ self addInstruction: (SLVMCall function: functionValue arguments: arguments) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> combineSampler: sampler with: texture [
	^ self combineSampler: sampler with: texture name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> combineSampler: sampler with: texture name: resultName [
	^ self addInstruction: (SLVMCombineSamplerWithTexture sampler: sampler texture: texture) name: resultName
]

{ #category : #constants }
SLVMBuilder >> constBool: aValue [
	^ SLVMConstant bool: aValue
]

{ #category : #constants }
SLVMBuilder >> constDouble: aValue [
	^ SLVMConstant double: aValue
]

{ #category : #constants }
SLVMBuilder >> constFloat: aValue [
	^ SLVMConstant float: aValue
]

{ #category : #constants }
SLVMBuilder >> constInt: aValue [
	^ SLVMConstant int: aValue
]

{ #category : #constants }
SLVMBuilder >> constLong: aValue [
	^ SLVMConstant long: aValue
]

{ #category : #constants }
SLVMBuilder >> constUInt: aValue [
	^ SLVMConstant uint: aValue
]

{ #category : #constants }
SLVMBuilder >> constULong: aValue [
	^ SLVMConstant ulong: aValue
]

{ #category : #accessing }
SLVMBuilder >> currentBlock [
	^ currentBlock
]

{ #category : #accessing }
SLVMBuilder >> currentBlock: anObject [
	currentBlock := anObject
]

{ #category : #instructions }
SLVMBuilder >> div: left with: right [
	^ self div: left with: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> div: left with: right name: resultName [
	^ self addOperation: #div left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> dynObjectIdentityEquals: left with: right [
	^ self dynObjectIdentityEquals: left with: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> dynObjectIdentityEquals: left with: right name: resultName [
	^ self addOperation: #dynObjectIdentityEquals left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> dynObjectIdentityNotEquals: left with: right [
	^ self dynObjectIdentityNotEquals: left with: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> dynObjectIdentityNotEquals: left with: right name: resultName [
	^ self addOperation: #dynObjectIdentityNotEquals left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> extractVector: aVectorValue element: indexValue [
	^ self extractVector: aVectorValue element: indexValue name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> extractVector: aVectorValue element: indexValue name: resultName [
	^ self addInstruction: (SLVMExtractVectorElement vector: aVectorValue index: indexValue) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> fadd: left with: right [
	^ self fadd: left with: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> fadd: left with: right name: resultName [
	^ self addOperation: #fadd left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> fdiv: left with: right [
	^ self fdiv: left with: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> fdiv: left with: right name: resultName [
	^ self addOperation: #fdiv left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> fmul: left with: right [
	^ self fmul: left with: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> fmul: left with: right name: resultName [
	^ self addOperation: #fmul left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> fneg: operand [
	^ self fneg: operand name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> fneg: operand name: resultName [
	^ self addOperation: #fneg operand: operand name: resultName
]

{ #category : #instructions }
SLVMBuilder >> frem: left with: right [
	^ self frem: left with: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> frem: left with: right name: resultName [
	^ self addOperation: #frem left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> fsub: left with: right [
	^ self fsub: left with: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> fsub: left with: right name: resultName [
	^ self addOperation: #fsub left: left right: right name: resultName
]

{ #category : #accessing }
SLVMBuilder >> function [
	^ function
]

{ #category : #accessing }
SLVMBuilder >> function: anObject [
	function := anObject
]

{ #category : #instructions }
SLVMBuilder >> getReference: reference element: element [
	^ self getReference: reference element: element resultName: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> getReference: reference element: element resultName: resultName [
	^ self addInstruction: (SLVMGetElementReference reference: reference index: element) name: resultName
]

{ #category : #testing }
SLVMBuilder >> isLastTerminator [
	^ currentBlock isLastTerminator
]

{ #category : #instructions }
SLVMBuilder >> jump: destination [
	^ self jump: destination name: function generateSymbol

]

{ #category : #instructions }
SLVMBuilder >> jump: destination name: resultName [
	^ self addInstruction: (SLVMJump destination: destination) name: resultName
]

{ #category : #accessing }
SLVMBuilder >> lastInstruction [
	^ currentBlock lastInstruction
]

{ #category : #instructions }
SLVMBuilder >> load: variable [
	^ self load: variable name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> load: variable name: resultName [
	^ self addInstruction: (SLVMLoadInstruction variable: variable) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> makeMatrix: matrixType arguments: arguments [
	^ self makeMatrix: matrixType arguments: arguments name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> makeMatrix: matrixType arguments: arguments name: resultName [
	^ self addInstruction: (SLVMMakeMatrix type: matrixType parameters: arguments) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> makeVector: vectorType arguments: arguments [
	^ self makeVector: vectorType arguments: arguments name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> makeVector: vectorType arguments: arguments name: resultName [
	^ self addInstruction: (SLVMMakeVector type: vectorType parameters: arguments) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> mul: left with: right [
	^ self mul: left with: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> mul: left with: right name: resultName [
	^ self addOperation: #mul left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> mulMatrix: left withMatrix: right [
	^ self mulMatrix: left withMatrix: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> mulMatrix: left withMatrix: right name: resultName [
	^ self addOperation: #mulMatrixMatrix left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> mulMatrix: left withVector: right [
	^ self mulMatrix: left withVector: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> mulMatrix: left withVector: right name: resultName [
	^ self addOperation: #mulMatrixVector left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> mulVector: left withMatrix: right [
	^ self mulVector: left withMatrix: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> mulVector: left withMatrix: right name: resultName [
	^ self addOperation: #mulVectorMatrix left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> neg: operand [
	^ self neg: operand name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> neg: operand name: resultName [
	^ self addOperation: #neg operand: operand name: resultName
]

{ #category : #'instance creation' }
SLVMBuilder >> newBasicBlock [
	^ self newBasicBlock: function generateSymbol
]

{ #category : #'instance creation' }
SLVMBuilder >> newBasicBlock: aName [
	| block |
	block := SLVMBasicBlock new name: aName.
	function addBasicBlock: block.
	^ block.
]

{ #category : #instructions }
SLVMBuilder >> not: operand [
	^ self not operand name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> not: operand name: resultName [
	^ self addOperation: #not operand: operand name: resultName
]

{ #category : #instructions }
SLVMBuilder >> phi: type [
	^ self phi: type name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> phi: type name: resultName [
	^ self addInstruction: (SLVMPhi type: type) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> rem: left with: right [
	^ self rem: left with: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> rem: left with: right name: resultName [
	^ self addOperation: #rem left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> return: value [
	^ self return: value name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> return: value name: resultName [
	^ self addInstruction: (SLVMReturn value: value) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> returnVoid [
	^ self returnVoid: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> returnVoid: resultName [
	^ self addInstruction: SLVMReturnVoid new name: resultName
]

{ #category : #instructions }
SLVMBuilder >> sample: combinedSampler implicitLodAtCoord: texcoord [
	^ self sample: combinedSampler implicitLodAtCoord: texcoord name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> sample: combinedSampler implicitLodAtCoord: texcoord name: resultName [
	^ self addInstruction: (SLVMSampleImplicitLod sampledTexture: combinedSampler texcoord: texcoord) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> send: selector returnType: returnType receiver: receiver arguments: arguments [
	^ self send: selector returnType: returnType receiver: receiver arguments: arguments name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> send: selector returnType: returnType receiver: receiver arguments: arguments name: resultName [
	^ self addInstruction: (SLVMSendMessage returnType: returnType receiver: receiver selector: selector arguments: arguments) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> shuffleVector: firstVector with: secondVector components: components [
	^ self shuffleVector: firstVector with: secondVector components: components name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> shuffleVector: firstVector with: secondVector components: components name: resultName [
	^ self addInstruction: (SLVMShuffleVectors firstVector: firstVector secondVector: secondVector components: components) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> store: value in: variable [
	^ self store: value in: variable name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> store: value in: variable name: resultName [
	^ self addInstruction: (SLVMStoreInstruction value: value variable: variable) name: resultName
]

{ #category : #instructions }
SLVMBuilder >> sub: left with: right [
	^ self sub: left with: right name: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> sub: left with: right name: resultName [
	^ self addOperation: #sub left: left right: right name: resultName
]

{ #category : #instructions }
SLVMBuilder >> unreachable [
	^ self unreachable: function generateSymbol
]

{ #category : #instructions }
SLVMBuilder >> unreachable: resultName [
	^ self addInstruction: SLVMUnreacheable new name: resultName
]

{ #category : #'as yet unclassified' }
SLVMBuilder >> withBasicBlock: aBasicBlock do: aBlock [
	| oldCurrentBlock |
	oldCurrentBlock := currentBlock.
	currentBlock := aBasicBlock.
	aBlock ensure: [ currentBlock := oldCurrentBlock ]
]

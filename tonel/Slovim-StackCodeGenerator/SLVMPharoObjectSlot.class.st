Class {
	#name : #SLVMPharoObjectSlot,
	#superclass : #SLVMPharoVariable,
	#instVars : [
		'pointer',
		'slotIndex',
		'slotOffset'
	],
	#category : #'Slovim-StackCodeGenerator-Pharo'
}

{ #category : #'code generation' }
SLVMPharoObjectSlot >> emitPushUsingLowcodeWith: aCodeGenerator [
	self isReceiverSlot ifTrue: [
		type isDynamicObjectPointerType ifTrue: [ 
			^ aCodeGenerator pushInstVar: slotIndex + 1
		] ifFalse: [
			aCodeGenerator
				pushReceiver;
				lowcodeFirstFieldPointer;
				lowcodePointerAddConstantOffset: slotOffset.
			^ type pushFromMemoryUsingLowcodeWith: aCodeGenerator
		].
	] ifFalse: [
		type isDynamicObjectPointerType ifTrue: [
			^ aCodeGenerator 
				visitExpression: pointer;
				lowcodeLoadObjectField: slotIndex
		] ifFalse: [
			aCodeGenerator
				visitExpression: pointer;
				lowcodeFirstFieldPointer;
				lowcodePointerAddConstantOffset: slotOffset.
			^ type pushFromMemoryUsingLowcodeWith: aCodeGenerator
		].
	]
]

{ #category : #'as yet unclassified' }
SLVMPharoObjectSlot >> emitPushWith: aCodeGenerator [
	self isReceiverSlot ifTrue: [
		type isDynamicObjectPointerType ifTrue: [ 
			^ aCodeGenerator pushInstVar: slotIndex + 1
		] ifFalse: [
			aCodeGenerator
				pushReceiver;
				pushLiteral: slotOffset;
				send: #_slvm_pointerAddOffset:.
			^ type loadValueFromPointerWith: aCodeGenerator
		].
	] ifFalse: [
		type isDynamicObjectPointerType ifTrue: [
			^ aCodeGenerator 
				visitExpression: pointer;
				pushLiteral: slotIndex + 1;
				send: #instVarAt:
		] ifFalse: [
			aCodeGenerator
				visitExpression: pointer;
				pushLiteral: slotOffset;
				send: #_slvm_pointerAddOffset:.
			^ type loadValueFromPointerWith: aCodeGenerator
		].
	]
]

{ #category : #'as yet unclassified' }
SLVMPharoObjectSlot >> emitStoreStackTopWith: aCodeGenerator [
	self halt.
	self isReceiverSlot ifTrue: [
		type isDynamicObjectPointerType ifTrue: [ 
			^ aCodeGenerator storeInstVar: slotIndex + 1
		] ifFalse: [
			aCodeGenerator pushReceiver;
				pushLiteral: slotOffset;
				send: #_slvm_pointerAddOffset:.
			^ type storeValueIntoPointerWith: aCodeGenerator.
		]
	] ifFalse: [ 
		self halt
	]
]

{ #category : #testing }
SLVMPharoObjectSlot >> isReceiverSlot [
	^ pointer isFunctionArgument and: [ pointer isReceiver ]
]

{ #category : #accessing }
SLVMPharoObjectSlot >> pointer [
	^ pointer
]

{ #category : #accessing }
SLVMPharoObjectSlot >> pointer: anObject [
	pointer := anObject
]

{ #category : #accessing }
SLVMPharoObjectSlot >> slotIndex [
	^ slotIndex
]

{ #category : #accessing }
SLVMPharoObjectSlot >> slotIndex: anObject [
	slotIndex := anObject
]

{ #category : #accessing }
SLVMPharoObjectSlot >> slotOffset [
	^ slotOffset
]

{ #category : #accessing }
SLVMPharoObjectSlot >> slotOffset: anObject [
	slotOffset := anObject
]

{ #category : #'as yet unclassified' }
SLVMPharoObjectSlot >> storeAndPopValue: value usingLowcodeWith: functionCodeGenerator [ 
	self isReceiverSlot ifTrue: [
		type isDynamicObjectPointerType ifTrue: [ 
			functionCodeGenerator
				visitExpression: value;
				storeInstVar: slotIndex + 1;
				popTop
		] ifFalse: [
			type isStructureType ifTrue: [ 
				functionCodeGenerator
					pushReceiver;
					lowcodeFirstFieldPointer;
					lowcodePointerAddConstantOffset: slotOffset;
					visitExpression: value.
			] ifFalse: [ 
				functionCodeGenerator
					visitExpression: value;
					pushReceiver;
					lowcodeFirstFieldPointer;
					lowcodePointerAddConstantOffset: slotOffset.
			].
			^ type storeAndPopStackTopIntoMemoryUsingLowcodeWith: functionCodeGenerator.
		].
	] ifFalse: [
		type isDynamicObjectPointerType ifTrue: [ 
			functionCodeGenerator
				visitExpression: pointer;
				pushLiteral: slotIndex + 1;
				visitExpression: value;
				send: #instVarAt:put:;
				popTop
		] ifFalse: [
			type isStructureType ifTrue: [ 
			functionCodeGenerator
				visitExpression: pointer;
				lowcodeFirstFieldPointer;
				lowcodePointerAddConstantOffset: slotOffset;
				visitExpression: value
			] ifFalse: [ 
				functionCodeGenerator
					visitExpression: value;
					visitExpression: pointer;
					lowcodeFirstFieldPointer;
					lowcodePointerAddConstantOffset: slotOffset.
			].

			^ type storeAndPopStackTopIntoMemoryUsingLowcodeWith: functionCodeGenerator
		]
	].

]

{ #category : #'as yet unclassified' }
SLVMPharoObjectSlot >> storeAndPopValue: value with: functionCodeGenerator [
	self isReceiverSlot ifTrue: [
		type isDynamicObjectPointerType ifTrue: [ 
			functionCodeGenerator
				visitExpression: value;
				storeInstVar: slotIndex + 1;
				popTop
		] ifFalse: [
			functionCodeGenerator
				visitExpression: value;
				pushReceiver;
				pushLiteral: slotOffset;
				send: #_slvm_pointerAddOffset:.
			^ type storeAndPopValueIntoPointerWith: functionCodeGenerator.
		].
	] ifFalse: [
		type isDynamicObjectPointerType ifTrue: [ 
			functionCodeGenerator
				visitExpression: pointer;
				pushLiteral: slotIndex + 1;
				visitExpression: value;
				send: #instVarAt:put:;
				popTop
		] ifFalse: [
			functionCodeGenerator
				visitExpression: value;
				visitExpression: pointer;
				pushLiteral: slotOffset;
				send: #_slvm_pointerAddOffset:.
			^ type storeAndPopValueIntoPointerWith: functionCodeGenerator.
		]
	].

]
